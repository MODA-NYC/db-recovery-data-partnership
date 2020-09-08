#!/usr/bin/python3
from office365.sharepoint.client_context import ClientContext
from office365.runtime.auth.client_credential import ClientCredential
from office365.runtime.auth.user_credential import UserCredential
import sys
import os

def mkdir_recursive(root_folder, path):
    # Similar to mkdir -p <path>
    stems = path.split('/')
    relative_folder = stems.pop(0)
    mkdir(root_folder, relative_folder)
    new_root_folder=f'{root_folder}/{relative_folder}'
    new_path='/'.join(stems)
    if len(stems) >= 1:
        mkdir_recursive(new_root_folder, new_path)

def mkdir(root_folder:str, relative_folder:str):
    # Similar to mkdir <path>
    root = ctx.web.get_folder_by_server_relative_url(root_folder)
    relative = root.folders.add(relative_folder)
    ctx.execute_query()
    print(f'new folder: {root_folder}/{relative_folder}')

def copy_file(local_path, target_path):
    # similar to `cp file.txt <sharepoint.com>/root/path/to/file.txt` 
    root = target_path.split('/')[0]
    parent = '/'.join(target_path.split('/')[1:-1])
    relative = '/'.join(target_path.split('/')[0:-1])
    file_name = target_path.split('/')[-1]
    mkdir_recursive(root, parent)

    # Load in the file to file_content
    with open(local_path, 'rb') as content_file:
        file_content = content_file.read()
    
    # Upload file to target path
    target_folder = ctx.web.get_folder_by_server_relative_url(relative)
    target_file = target_folder.upload_file(file_name, file_content)
    ctx.execute_query()
    print(f'Copied {local_path} to {target_path}')

if __name__ == "__main__":
    settings=dict(
        url=os.environ['SHAREPOINT_URL'],
        client_credentials=dict(
            client_id=os.environ.get('SHAREPOINT_CLIENT_ID', ''),
            client_secret=os.environ.get('SHAREPOINT_CLIENT_SECRET', '')
        ),
        user_credentials=dict(
            username=os.environ.get('SHAREPOINT_USERNAME', ''),
            password=os.environ.get('SHAREPOINT_PASSWORD', '')
        )
    )

    # ctx = ClientContext(settings['url']).with_credentials(
    # ClientCredential(settings['client_credentials']['client_id'],
    #                  settings['client_credentials']['client_secret']))

    ctx = ClientContext.connect_with_credentials(
            settings['url'],
            UserCredential(
                settings['user_credentials']['username'],
                settings['user_credentials']['password']
                )
            )
    
    local_path=sys.argv[1]
    target_path=sys.argv[2]
    copy_file(local_path, target_path)