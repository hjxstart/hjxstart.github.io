user-interface vty 0 4
  authentication-mode aaa
  protocol inbound ssh
  user privilege level 15
  quit

aaa
  local-user python password irreverisble-cipher Huawei@123
  local-user python service-type ssh
  local-user python privilege level 15
  local-user python password irreverisble-cipher Huawei@123
  local-user python service-type ssh
  local-user python privilege level 15
  local-aaa-user password policy administrator
    undo password alter orginal
    quit
  quti

stelnet server enable
  ssh server-source all-interface
  ssh user python
  ssh user python authentication-type password
  ssh user python service-type stelnet

sftp server enable
  ssh user python service-type all
  ssh user python sftp-directory flash:/
  quit

netconf
  source ip interface loopback 0 port 830
  quit

####################################################
user-interface vty 0 r
  authentication-mode aaa
  protocol inbound ssh
  user privilege level 15
  quit

aaa
  local-user python password irreversible-cipher Huawei@123
  local-user python service-type ssh
  local-user python privilege level 15
  local-user netconf password irreversible-cipher Huawei@123
  local-user netconf service-type api
  local-user netconf privilege level 15
  local-aaa-user password policy administrator
    undo password alter original
    quit
  quit

stelnet server enable
  ssh server-source all-interface
  ssh user python 
  ssh user python authentication-type pass
  ssh user python service-type stelnet
  quit

sftp server enable
  ssh user python service-type all
  ssh user python sftp-directory flash:/
  quit

netconf
  source ip interface loopback 0 port 830
  quit
#############################################

user-interface vty 0 4
  authentication-mode aaa
  protocol inbound ssh
  user privilege level 15
  quit

aaa
  local-user python password irreversible-cipher Huawei@123
  local-user python service-type ssh
  local-user python privilege level 15
  local-user python password irreversible-cipher Huawei@123
  local-user python service-type api
  local-user python privilege level 15
  local-aaa-user password policy administrator
    undo password alter original
    quit
  quit

stelnet server enable
  ssh server-source all-interface
  ssh user python
  ssh user python authentication-type password
  ssh user python service-type stelnet
  quit

sftp server enable
  ssh user python service-type all
  ssh user python sftp-directory flash:/
  quit

netconf
  source ip interface loopback 0 port 830
  quiit

################################################


user-interface vty 0 4
  authentication-mode aaa
  protocol inbound ssh
  user privilege level 15
  quit

aaa
  local-user python password irreversible-cipher Huawei@123
  local-user python service-type ssh
  local-user python privilege level 15
  local-user netconf password irreversible-cipher Huawei@123
  local-user netconf service-type api
  local-user netconf privilege level 15
  local-aaa-user password policy administrator
    undo password alter original
    quit
  quit

stelnet server enable
  ssh server-source all-interface
  ssh user python
  ssh user python authentication-type password
  ssh user python service-type stelnet
  quit

sftp server enable
  ssh user python service-type all
  ssh user python sftp-directory flash:/
  quit

netconf
  source ip interface loopback 0 port 830
  quit

#######################################################


user-itnerface vty 0 4
  authentication-mode aaa
  protocol inbond ssh
  user privilege level 15
  quit

aaa
  local-user python password irreversible-cipher Huawei@123
  local-user python service-type ssh
  local-user python privilege level 15
  local-user netconf password irreversible-cipher Huawei@123
  local-user netconf service-type api
  local-user netconf privilege level 15
  local-aaa-user password policy administrator
    undo password alter original
    quit
  quit

stelnet server enable
  ssh server-source all-interface
  ssh user python
  ssh user python authentication-type password
  ssh user python service-type stelnet
sftp server enable
  ssh user python service-type all
  ssh user python sftp-directory flash:/
  quti

netconf
  source ip interface loopback 0 port 830
  quit
quit





