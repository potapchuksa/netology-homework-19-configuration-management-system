#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2024, Sergey <your.email@example.org>
# GNU General Public License v3.0+

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: file_creator

short_description: Creates a text file with specified content on remote host

version_added: "1.0.0"

description:
    - This module creates or updates a text file on the remote host.
    - Supports idempotency: only changes file if content differs.
    - Supports check mode and file permissions.

options:
    path:
        description:
            - Full absolute path to the file to create or update.
            - Parent directories will be created if they don't exist.
        required: true
        type: str
    content:
        description:
            - The content to write into the file.
        required: true
        type: str
    mode:
        description:
            - File permissions in octal notation (e.g., '0644', '0600').
        required: false
        type: str
        default: '0644'

author:
    - Potapchuk Sergey (@potapchuksa)
'''

EXAMPLES = r'''
# Create a simple file
- name: Create test file
  my_own_namespace.yandex_cloud_elk.file_creator:
    path: /tmp/test.txt
    content: "Hello, Ansible!"

# Create config file
- name: Create app config
  my_own_namespace.yandex_cloud_elk.file_creator:
    path: /etc/myapp/app.conf
    content: "debug=true\nlog_level=info"
    mode: '0644'
'''

from ansible.module_utils.basic import AnsibleModule
import os
import hashlib


def get_file_hash(filepath):
    """Calculate MD5 hash of file content for comparison."""
    if not os.path.exists(filepath):
        return None
    with open(filepath, 'rb') as f:
        return hashlib.md5(f.read()).hexdigest()


def run_module():
    # Define module arguments
    module_args = dict(
        path=dict(type='str', required=True),
        content=dict(type='str', required=True, no_log=False),
        mode=dict(type='str', required=False, default='0644')
    )

    # Seed result dict
    result = dict(
        changed=False,
        path='',
        content_length=0
    )

    # Instantiate AnsibleModule
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # Extract parameters
    path = module.params['path']
    content = module.params['content']
    mode = module.params['mode']
    
    result['path'] = path
    result['content_length'] = len(content)
    
    # Calculate hashes for idempotency check
    file_exists = os.path.exists(path)
    current_hash = get_file_hash(path) if file_exists else None
    desired_hash = hashlib.md5(content.encode('utf-8')).hexdigest()
    
    # If file exists and content is identical — no change needed
    if file_exists and current_hash == desired_hash:
        module.exit_json(**result)
    
    # Change is required
    result['changed'] = True
    
    # Check mode: report change but don't modify anything
    if module.check_mode:
        module.exit_json(**result)
    
    try:
        # Create parent directories if needed
        dir_path = os.path.dirname(path)
        if dir_path and not os.path.exists(dir_path):
            os.makedirs(dir_path, mode=0o755)
        
        # Write content to file
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        # Set file permissions
        os.chmod(path, int(mode, 8))
        
    except Exception as e:
        module.fail_json(msg=f"Failed to create file: {str(e)}", **result)
    
    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
