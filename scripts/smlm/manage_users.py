#!/usr/bin/python3
#
# Author/s: Raul Mahiques
# License: GPLv3
# 
# $Id$
#

from xmlrpc.client import ServerProxy
import ssl, argparse, yaml



def smlm_login(server, user, pwd):
  """
  Performs an authentication login and returns the session key
  """
  context = ssl._create_unverified_context()
  client = ServerProxy('https://' + server + '/rpc/api', context=context)
  key = client.auth.login(user, pwd)
  return key, client


def smlm_logout(key, client):
  """
  Performs a logout
  """
  client.auth.logout(key)


def smlm_create_user(key, client, login, password, firstName=None, lastName=None, email=None):
  """
  Creates a user
  """
  if(firstName == None):
    firstName=login
  if(lastName == None):
    lastName=login
  if(email == None):
    email=login+"@"+login+"."+login

  users = client.user.create(key, login, password, firstName, lastName, email)
  return users

def smlm_addRole_user(key, client, login, role):
  """
  Adds a role to the user
  """
  users = client.user.addRole(key, login, role)
  return users


def smlm_enable_user(key, client, login):
  """
  Enable user
  """
  users = client.user.enable(key, login)
  return users


def smlm_setErrataNotifications_user(key, client, login, value=False):
  """
  Enables/disables errata mail notifications for a specific user.
  """
  users = client.user.setErrataNotifications(key, login, value)
  return users


def smlm_setReadOnly_user(key, client, login, readOnly=True):
  """
  Sets whether the target user should have only read-only API access or standard full scale access.
  """
  users = client.user.setReadOnly(key, login, readOnly)
  return users




def main():
  """
  Main function that parses the command-line arguments and initiate the API calls.
  """
  # Define how we want to process command line arguments
  parser = argparse.ArgumentParser(prog='smlm_user',description='Manages SMLM Users')
  group = parser.add_mutually_exclusive_group(required=True)
  group.add_argument('-a','--add', action='store_true', help='Add Organization')
  group.add_argument('-d','--delete', action='store_true', help='Delete Organization')
  group.add_argument('-g','--get', action='store_true', help='Retrieve Organization information')
  group.add_argument('-l','--list', action='store_true', help='List Organizations')
  parser.add_argument('-u', '--user', type=str, required=True, help='User name with privileges to create other users')
  parser.add_argument('-p', '--pwd', type=str, required=True, help='Password for user')
  parser.add_argument('-s', '--server', type=str, required=True, help='Server FQDN')
  parser.add_argument('--nusr', type=str, required=True, help='New user login name.')
  parser.add_argument('--npwd', type=str, required=True, help='New user password.')
  parser.add_argument('--nfirstname', type=str, help="New user first name.")
  parser.add_argument('--nlastname', type=str, help="New user last name.")
  parser.add_argument('--nemail', type=str, help="New user e-mail.")
  parser.add_argument('--nrole', required=True, type=str, help='New user role' )
  parser.add_argument('--debug', action='store_true', help="Use it to enable debug messages.")
  inputparam=parser.parse_args()

  context = ssl._create_unverified_context()
  client = ServerProxy('https://' + inputparam.server + '/rpc/api', context=context)

  key, client = smlm_login(inputparam.server, inputparam.user, inputparam.pwd)

  if(inputparam.add):
    print("We add " + str(inputparam.nusr))
    smlm_create_user(key, client, inputparam.nusr, inputparam.npwd, inputparam.nfirstname or None, inputparam.nlastname or None, inputparam.nemail or None )
    smlm_addRole_user(key, client, inputparam.nusr, inputparam.nrole)
    smlm_enable_user(key, client, inputparam.nusr)
    smlm_setErrataNotifications_user(key, client, inputparam.nusr)
    smlm_setReadOnly_user(key, client, inputparam.nusr)


    smlm_add_org(key, client, inputparam.orgname, inputparam.admusr, inputparam.admpwd, inputparam.admprefix, inputparam.admfirstname, inputparam.admlastname, inputparam.admemail, inputparam.usepam or False)
  elif(inputparam.delete):
    print("Not implemented yet")
#    print("We delete " + str(inputparam.orgname))
#    orgid=smlm_get_orgid(key, client, inputparam.orgname)
#    smlm_del_org(key, client, orgid)
  elif(inputparam.get):
    print("Not implemented yet")
#    print("We retrive information about: " + str(inputparam.orgname))
#    print(str(smlm_get_org(key, client, inputparam.orgname)))
  elif(inputparam.list):
    print("Not implemented yet")
#    print("We are retrieving the list of organizations")
#    print(yaml.dump(smlm_list_orgs(key, client)))
  else:
    print("Invalid or missing parameters")
    if(inputparam.debug):
      print(yaml.dump(inputparam))

  smlm_logout(key, client)



if __name__ == '__main__':
  main()




