# Active-Directory-Homelab
Active Directory homelab built with Windows Server 2019 and VirtualBox. Demonstrates enterprise infrastructure deployment including Domain Controller configuration, DHCP scopes, NAT routing, and PowerShell automation to provision 1,000+ domain users.  

# **Homelab Setup Documentation**

## **I. Prerequisites & Installations**

Before beginning the configuration, ensure the following software is installed and available:

  - **Windows Server 2019 (WS19)** ISO
  - **Windows 10** ISO
  - **Oracle VirtualBox**

## **II. Setting Up The Domain Controller (DC)**

### **Task 1: VirtualBox Provisioning and Base OS Setup**

1. Open VirtualBox and click **New** to create a VM. Name it DC (Domain Controller).
2. Set the **ISO Image** to your downloaded WS19 ISO, uncheck **Proceed with Unattended Installation**, and click **Finish**.
3. Select the VM and go to **Settings > Expert > System** to customize your CPU and memory allocation to your preference.
4. Go to **General > Features** and set both **Shared Clipboard** and **Drag-and-Drop** to **Bidirectional**.
5. Go to **Network > Adapter 2** (ensure the VM is powered off). Check **Enable Network Adapter**, change **Attached to** to **Internal Network**, and click **OK**.
6. Start the VM. Set the OS to **Windows Server 2019 Standard Evaluation (Desktop Experience)** and select **Custom** when prompted for the installation type.
7. Select your drive and complete the Windows setup.

### **Task 2: Guest Additions, Networking, and Hostname Configuration**

1. At the pre-login screen, click the VirtualBox menu: **Input > Keyboard > Insert Ctrl-Alt-Del**, then log in.
2. At the top of VM, click **Devices > "Insert Guest Additions CD Image"**
3. Open **File Explorer > This PC > D:** and run the VBoxWindowsAdditions-amd64 application.
4. When prompted to reboot, select **I want to manually reboot later**, finish the setup, and **Shut down** the VM.
5. Turn the VM back on and log in.
6. Click **WIN + R**, enter **ncpa.cpl**. Click on **Ethernet 2**, then click **Properties**.
7. Select **Internet Protocol Version 4 (TCP/IPv4)** and click **Properties**.
8. Apply the following static IP settings:
  - **IP address:** 172.16.0.1
  - **Subnet mask:** 255.255.255.0
  - **Preferred DNS server:** 127.0.0.1
9. Save the settings.
10. Right-click **Ethernet**, select **Rename**, and change it to \_INTERNET\_.
11. Right-click **Ethernet 2**, select **Rename**, and change it to \_Internal\_.
12. Right-click the Start button > **System > Rename this PC**. Rename it to DC, click **Next**, and select **Restart later**.
13. **Shut down** the VM completely, then start it again.

### **Task 3: AD DS Installation and Domain Controller Promotion**

1. Open **Server Manager** and click **Add roles and features**.
2. Click **Next** until you reach the **Server Roles** page. Check **Active Directory Domain Services**.
3. Click **Next** until you reach the Confirmation page, then click **Install**.
4. Once the installation completes, close the wizard and click the flag icon with a yellow warning sign at the top of Server Manager.
5. Click **Promote this server to a domain controller**.
6. Select **Add a new forest**, set the Root domain name to mydomain.com, and click **Next**.
7. Create a **Directory Services Restore Mode (DSRM)** password of your choice.
8. Click **Next** until the Prerequisites Check finishes, then click **Install**. _(Note: The VM may reboot automatically once finished)._

**Note:** When logging in after the reboot, you will see MYDOMAIN\\Administrator above the password field, indicating you are now on the domain.

### **Task 4: Creating an Organizational Unit and Admin User**

1. Click **Start > Windows Administrative Tools > Active Directory Users and Computers**.
2. Right-click mydomain.com > **New > Organizational Unit**. Name it \_ADMINS and click **OK**.
3. Right-click the new \_ADMINS OU > **New > User**.
4. Enter your First Name and Last Name. Set the **User logon name** using this syntax: a-&lt;first initial&gt;&lt;last name&gt;. Click **Next**.
5. Type a secure password. Uncheck **User must change password at next logon** and check **Password never expires**. Click **Next**, then **Finish**.
6. Right-click the newly created user > **Properties > Member Of > Add**.
7. Type domain admins, click **Check Names**, then click **OK > Apply > OK**.

### **Task 5: Installing Remote Access and Enabling NAT**

1. In **Server Manager**, click **Add roles and features**.
2. Click **Next** to **Server Roles**, check **Remote Access**, and click **Next**.
3. On the **Role Services** page, check **Routing**. Click **Next** to Confirmation, **Install**, and close when finished.
4. Go to **Server Manager > Tools > Routing and Remote Access**.
5. Right-click **DC (local)** > **Configure and Enable Routing and Remote Access**.
6. Click **Next**, select **Network address translation (NAT)**, and click **Next**. Try again if it does not work.
7. Ensure **Use this public interface to connect to the Internet** is selected, choose the \_INTERNET\_ interface, click **Next**, then **Finish**.

**Note:** The DC (local) icon should now display a green indicator.

### **Task 6: Installing DHCP Server and Configuring a Scope**

1. In **Server Manager**, click **Add roles and features**.
2. Click **Next** to **Server Roles**, select **DHCP Server**, and proceed to **Install**.
3. Go to **Server Manager > Tools > DHCP**.
4. Expand dc.mydomain.com, right-click **IPv4**, and select **New Scope**.
5. Name the scope 172.16.0.100-200 and click **Next**.
6. Configure the IP Address Range:
  - **Start IP address:** 172.16.0.100
  - **End IP address:** 172.16.0.200
  - **Length:** 24
7. Click **Next** until prompted for the Default Gateway. Enter 172.16.0.1.
8. Continue to click **Next** to Finish.
9. In the DHCP window, right-click dc.mydomain.com and click **Authorize**.
10. Right-click dc.mydomain.com again and click **Refresh**.

**Note:** IPv4 should now have a green checkmark.

### **Task 7: Importing Bulk Users into Active Directory**

1. Go to **Server Manager > Local Server**. Under "Properties for DC," find **IE Enhanced Security Configuration** and turn it **Off** for both Administrators and Users.
2. At the top of your VM window, click **Devices > Shared Clipboard > Bidirectional**.
3. Open Internet Explorer and paste the following URL into the address bar: [https://github.com/stackingboxes/Active-Directory-Homelab/raw/refs/heads/main/AD_PS.zip]
4. Click **Save > Open folder**. Right-click the downloaded zip file and select **Extract All**.
5. Change the extraction destination to your Desktop (e.g., C:\\Users\\Administrator\\Desktop).
6. On your desktop, open the extracted AD_PS folder. Open the names file, add your first and last name to the very top, and press Ctrl + S to save.
7. Right-click the 1_CREATE_USERS script, select **Run with PowerShell**, click **Open**, and type Y to confirm.
8. Open **Active Directory Users and Computers** and check the \_USERS OU. You should now see 1,000+ users, including your own account.

## **III. Client Machine Configuration**

### **Task 8: Creating a Client Machine and Adding it to AD**

1. In VirtualBox, create a new machine and name it CLIENT1.
2. Under **ISO Image**, select your Windows 10 ISO. Uncheck **Proceed with Unattended Installation** and click **Finish**.
3. Select CLIENT1 > **Settings > Network**. Change **Attached to** to **Internal Network**, click **OK**, and start the machine.
4. Proceed through the Windows 10 setup: click **Install now > I don't have a product key > Windows 10 Pro > Accept terms > Custom**.
5. Once the OS finishes installing and reboots, skip standard setup elements: **Yes > Yes > Skip > I don't have internet > Continue with limited setup**.
6. Enter CLIENT1 as the username, leave the password field empty, click **Next**, then **Accept > Not now**.
7. Ensure your DC VM is open and logged in.
8. On the client machine, if prompted to make the PC discoverable on the network, click **Yes**.
9. In the Windows search bar, type about, press Enter, and scroll down to **Related settings**. Click **Rename this PC (advanced)**, then click **Change...**.
10. Select **Domain** and enter mydomain.com. Verify the computer name is CLIENT1 and click **OK**.
11. Authenticate the domain join using the custom user you generated with the PowerShell script.
  - **Username format:** &lt;first initial&gt;&lt;last name&gt;01 (e.g., Rabin Chuwan = rchuwan01)
  - **Password:** Password1
12. A "Welcome to the mydomain.com domain" message will appear. **Restart** CLIENT1.
13. On the DC VM, open **Active Directory Users and Computers** and check the **Computers** directory. CLIENT1 should now be listed successfully.
