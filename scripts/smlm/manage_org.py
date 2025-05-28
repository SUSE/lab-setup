#!/usr/bin/python3
#
# Authors: Ricardo Mateus, Raul Mahiques
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


def smlm_add_org(key, client, orgname, admusr, admpwd, admprefix, admfirstname, admlastname, admemail, admusepam):
  """
  Creates an organization in SMLM with an admin user
  """
  systems = client.org.create(key, orgname, admusr, admpwd, admprefix, admfirstname, admlastname, admemail, admusepam)


def smlm_get_org(key, client, orgname):
  """
  Returns information about an organization in SMLM
  """
  print(yaml.dump(lient.org.getDetails(key, orgname)))
  

def smlm_list_orgs(key, client):
  """
  Returns the list of organization in SMLM
  """
  return client.org.listOrgs(key)


def smlm_get_orgid(key, client, orgname):
  """
  Retrieves information about a SMLM organization and returns the organization ID.
  """
  orgDetails = client.org.getDetails(key, orgname)
  return orgDetails['id']


def smlm_del_org(key, client, orgid):
  """
  Deletes an organization from SMLM
  """
  print(orgid)
  result = client.org.delete(key, orgid)
  print(result)


def main():
  """
  Main function that parses the command-line arguments and initiate the API calls.
  """
  # Define how we want to process command line arguments
  parser = argparse.ArgumentParser(prog='smlm_org',description='Manages SMLM Organizations')
  group = parser.add_mutually_exclusive_group(required=True)
  group.add_argument('-a','--add', action='store_true', help='Add Organization')
  group.add_argument('-d','--delete', action='store_true', help='Delete Organization')
  group.add_argument('-g','--get', action='store_true', help='Retrieve Organization information')
  group.add_argument('-l','--list', action='store_true', help='List Organizations')
  parser.add_argument('-u', '--user', type=str, required=True, help='User name with privileges to create organizations')
  parser.add_argument('-p', '--pwd', type=str, required=True, help='Password for user')
  parser.add_argument('-s', '--server', type=str, required=True, help='Server FQDN')
  parser.add_argument('-o','--orgname', type=str, help='Organization name. Must meet same criteria as in the web UI.')
  parser.add_argument('--admusr', type=str, help='New administrator login name.')
  parser.add_argument('--admpwd', type=str, help='New administrator password.')
  parser.add_argument('--admprefix', type=str, help="New administrator’s prefix. Must match one of the values available in the web UI. (i.e. Dr., Mr., Mrs., Sr., etc.)")
  parser.add_argument('--admfirstname', type=str, help="New administrator’s first name.")
  parser.add_argument('--admlastname', type=str, help="New administrator’s last name.")
  parser.add_argument('--admemail', type=str, help="New administrator’s e-mail.")
  parser.add_argument('--admusepam', action='store_true', help='True if PAM authentication should be used for the new administrator account.', dest="usepam" )
  parser.add_argument('--debug', action='store_true', help="Use it to enable debug messages.")
  inputparam=parser.parse_args()

  context = ssl._create_unverified_context()
  client = ServerProxy('https://' + inputparam.server + '/rpc/api', context=context)

  key, client = smlm_login(inputparam.server, inputparam.user, inputparam.pwd)

  if(inputparam.add and inputparam.orgname and inputparam.admusr and inputparam.admpwd and inputparam.admprefix and inputparam.admfirstname and inputparam.admlastname and inputparam.admemail):
    print("We add " + str(inputparam.orgname))
    smlm_add_org(key, client, inputparam.orgname, inputparam.admusr, inputparam.admpwd, inputparam.admprefix, inputparam.admfirstname, inputparam.admlastname, inputparam.admemail, inputparam.usepam or False)
  elif(inputparam.delete):
    print("We delete " + str(inputparam.orgname))
    orgid=smlm_get_orgid(key, client, inputparam.orgname)
    smlm_del_org(key, client, orgid)
  elif(inputparam.get):
    print("We retrive information about: " + str(inputparam.orgname))
    print(str(smlm_get_org(key, client, inputparam.orgname)))
  elif(inputparam.list):
    print("We are retrieving the list of organizations")
    print(yaml.dump(smlm_list_orgs(key, client)))
  else:
    print("Invalid or missing parameters")
    if(inputparam.debug):
      print(yaml.dump(inputparam))

  smlm_logout(key, client)



if __name__ == '__main__':
  main()


