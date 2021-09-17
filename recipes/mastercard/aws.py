import boto3
import os
import time
from botocore.errorfactory import ClientError
import pprint
import tempfile
import shutil

class Aws:
    def __init__(
        self,
        aws_region_name,

        # S3 credentials 
        rdp_access_key_id,
        rdp_secret_access_key,

        # Athena Credentials
        aws_access_key_id,
        aws_secret_access_key,
    ):

        """ 
        initialize class Aws with the following attributes
        athena, s3, s3_client
        """

        self.athena = boto3.client(
            "athena",
            region_name=aws_region_name,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
        )

        self.s3 = boto3.Session(
            aws_access_key_id=rdp_access_key_id,
            aws_secret_access_key=rdp_secret_access_key,
        ).resource("s3")

        self.s3_client = boto3.client(
            "s3",
            region_name=aws_region_name,
            aws_access_key_id=rdp_access_key_id,
            aws_secret_access_key=rdp_secret_access_key,
        )

        self.bucket = "recovery-data-partnership"
        self.temporary_location = f"{self.bucket}/tmp/"
        self.pp=pprint.PrettyPrinter(indent=4)

    def execute_query(self, query: str, database: str, output: str):
        """
        This is the interface function that 
        1. start query
        2. wait for output to materialize
        3. move output to target location
        """

        queryId, queryLoc, queryMetadata = self.start_query(query, database)
        response = self.wait_till_finish(queryId)
        if response["Status"] == "SUCCEEDED":
            moved = self.move_compress_output(queryLoc, queryMetadata, output)
            if moved:
                print("Done !\n")
        self.pp.pprint(response)

    def start_query(self, query: str, database: str) -> str:
        """
        Start a Query and return queryId
        https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/athena.html#Athena.Client.start_query_execution
        """
        queryStart = self.athena.start_query_execution(
            QueryString=query,
            QueryExecutionContext={"Database": database},
            ResultConfiguration={"OutputLocation": f"s3://{self.temporary_location}"},
        )
        queryId = queryStart["QueryExecutionId"]
        queryLoc = f"{self.temporary_location}{queryId}.csv"
        queryMetadata = f"{self.temporary_location}{queryId}.csv.metadata"

        return queryId, queryLoc, queryMetadata

    def get_query_status(self, queryId: str):
        """
        Check the status of the query
        https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/athena.html#Athena.Client.batch_get_query_execution
        """
        response = self.athena.batch_get_query_execution(QueryExecutionIds=[queryId])
        QueryExecution = response["QueryExecutions"][0]
        UnprocessedQueryExecutionId = response["UnprocessedQueryExecutionIds"][0] if len(response["UnprocessedQueryExecutionIds"]) > 0 else {}
        return QueryExecution, UnprocessedQueryExecutionId

    def wait_till_finish(self, queryId: str):
        QueryExecution, UnprocessedQueryExecutionId = self.get_query_status(queryId)
        status = QueryExecution["Status"]["State"]
        TotalExecutionTimeInSeconds = (
                    QueryExecution["Statistics"]["TotalExecutionTimeInMillis"] / 1000
                )
        print(f"Time elapsed: {TotalExecutionTimeInSeconds} Status: {status}")
        
        if status in ("QUEUED", "RUNNING"):
            # If query is in queue, or query is running, 
            # then sleep for 10s then check status again
            time.sleep(10)
            return self.wait_till_finish(queryId)

        if status in ("SUCCEEDED", "FAILED", "CANCELLED"):
            # If status in any above, 
            # then break recursion and make response
            response = {
                "Status": status,
                "Exception": UnprocessedQueryExecutionId,
                "Stats": QueryExecution["Statistics"],
            }
            return response

    def move_output(self, queryLoc: str, queryMetadata: str, outputLoc: str):
        """
        1. Assuming file is ready, then copy file (queryLoc -> outputLoc)
        2. Remove file from temporary location (queryLoc, queryMetadata)
        """
        if self.check_file_exisitence(outputLoc):
            # Delete old file before uploading new file
            self.s3.Object(self.bucket, outputLoc).delete()
        
        self.s3.Object(self.bucket, outputLoc).copy_from(CopySource=queryLoc)
        return self.remove_temp_files(queryLoc, queryMetadata, outputLoc)

    def remove_temp_files(self, queryLoc: str, queryMetadata: str, outputLoc: str):
        if self.check_file_exisitence(outputLoc):
            # If file is successly moved queryLoc -> outputLoc
            # Then delete the files stored at temporary location
            self.s3.Object(self.bucket, queryLoc).delete()
            self.s3.Object(self.bucket, queryMetadata).delete()

            if self.check_file_exisitence(queryLoc) == self.check_file_exisitence(
                queryMetadata
            ):
                print("Filed moved, clean up complete")
                return True
            else:
                print("Filed moved, clean up incomplete")
                return False
        else:
            print("Filed not moved, cannot proceed")
            return False

    def move_compress_output(self, queryLoc: str, queryMetadata: str, outputLoc: str):
        """
        1. Assuming file is ready, then 
            1. download file queryLoc
            2. compress locally
            3. upload to outputLoc
        2. Remove file from temporary location (queryLoc, queryMetadata)
        """
        zipFileName = outputLoc.split('/')[-1].replace(f'{self.bucket}/', '')
        csvFileName = zipFileName.replace('.zip','')

        # The file will be downloaded to the temporary directory
        tempdir = tempfile.mkdtemp()
        zipFielPath = tempdir + '/' + zipFileName
        csvFilePath = tempdir + '/' + csvFileName

        self.download_file(
            queryLoc.replace(f'{self.bucket}/', ''), 
            csvFilePath
        )
        self.file_compression(csvFilePath, zipFielPath)

        if self.check_file_exisitence(outputLoc):
            # Delete old file before uploading new file
            self.s3.Object(self.bucket, outputLoc).delete()
    
        self.upload_file(zipFielPath, outputLoc)     
        shutil.rmtree(tempdir)   
        return self.remove_temp_files(queryLoc, queryMetadata, outputLoc)
        
    
    def download_file(self, objectLoc:str, outputLoc:str):
        if self.check_file_exisitence(objectLoc):
            with open(outputLoc, 'wb') as data:
                self.s3.Object(self.bucket, objectLoc)\
                    .download_fileobj(data)
            print(f'{objectLoc} downloaded to {outputLoc}')
        else: 
            print(f'{objectLoc} doesn\'t exist')

    def file_compression(self, csvFilePath:str, zipFielPath:str):
        tmpdir='/'.join(csvFilePath.split('/')[:-1])
        csvFileName=csvFilePath.split('/')[-1]
        zipFileName=csvFilePath.split('/')[-1]+'.zip'

        os.system(f'pwd')
        os.system(f'( cd {tmpdir} && zip -9 {zipFileName} {csvFileName} )')
        os.system(f'rm {csvFilePath}')
        print(f'{csvFilePath} compressed to {zipFielPath}')
    
    def upload_file(self, localPath:str, outputLoc:str):
        with open(localPath, 'rb') as data:
            self.s3.Object(self.bucket, outputLoc)\
                .upload_fileobj(data)
        print(f'{localPath} uploaded to {outputLoc}')

    def check_file_exisitence(self, fileLoc):
        """
        Given file location (fileLoc), check if file exists
        if exists, return True, else False
        """
        try:
            self.s3_client.head_object(Bucket=self.bucket, Key=fileLoc)
            return True
        except ClientError:
            return False