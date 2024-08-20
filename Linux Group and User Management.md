# Linux Group and User Management

## Group Management in Linux

There are two categories of groups in the Linux operating system:
- **Primary Group**: Automatically generated when creating a user. A group with the same ID as the user ID is created, and the user is added to it as the first and only member.
- **Secondary Group**: Created separately using commands, and users can be added to it.

### Commands for Group Management

1. **Create a Group (Secondary Group)**:
   ```bash
   groupadd group_name
   ```
   *Example*: `groupadd Group1`

2. **Set the Password for the Group**:
   ```bash
   gpasswd group_name
   ```
   *Example*: `gpasswd Group1`

3. **Display the Group Password File**:
   ```bash
   cat /etc/gshadow
   ```
   *Note*: Use `cat /etc/group` for more detailed group information.

4. **Add a User to an Existing Group**:
   ```bash
   usermod -G group_name username
   ```
   *Example*: `usermod -G group1 John_Doe`

   *Note*: This command removes the user from previous groups. To prevent this, use the `-aG` option.

5. **Add User to Group Without Removing From Existing Groups**:
   ```bash
   usermod -aG group_name username
   ```
   *Example*: `usermod -aG group1 John_Doe`

6. **Add Multiple Users to a Group at Once**:
   ```bash
   gpasswd -M username1,username2,username3,...,usernamen group_name
   ```
   *Example*: `gpasswd -M Person1,Person2,Person3 Group1`

7. **Delete a User From a Group**:
   ```bash
   gpasswd -d username group_name
   ```
   *Example*: `gpasswd -d Person1 Group1`

8. **Delete a Group**:
   ```bash
   groupdel group_name
   ```
   *Example*: `groupdel Group1`

## User Management in Linux

A user in Linux is an entity with a unique ID that can perform operations on files and more. User IDs are assigned as follows:
- ID 0: Root user
- IDs 1 to 999: System users
- IDs 1000 onwards: Local users

### Commands for User Management

1. **List All Users**:
   ```bash
   awk -F':' '{ print $1}' /etc/passwd
   ```

2. **Get User ID**:
   ```bash
   id username
   ```
   *Example*: `id test`

3. **Add a New User**:
   ```bash
   sudo useradd username
   ```
   *Example*: `sudo useradd geeks`

4. **Assign a Password to a User**:
   ```bash
   passwd username
   ```
   *Example*: `passwd geeks`

5. **Access User Configuration File**:
   ```bash
   cat /etc/passwd
   ```

6. **Change User ID**:
   ```bash
   sudo usermod -u new_id username
   ```
   *Example*: `sudo usermod -u 1982 test`

7. **Modify the Group ID of a User**:
   ```bash
   sudo usermod -g new_group_id username
   ```
   *Example*: `sudo usermod -g 1005 test`

8. **Change User Login Name**:
   ```bash
   sudo usermod -l new_login_name old_login_name
   ```
   *Example*: `sudo usermod -l John_Wick John_Doe`

9. **Change User's Home Directory**:
   ```bash
   usermod -d new_home_directory_path username
   ```
   *Example*: `usermod -d /new_home_directory test`

10. **Delete a User**:
    ```bash
    sudo userdel -r username
    ```
    *Example*: `sudo userdel -r new_geeks`
```

