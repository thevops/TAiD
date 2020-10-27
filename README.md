Ansible-Docker environment for testing purposes
===============================================

Create Docker containers that act as real servers based on Debian 10 with systemd.



What should you customize?
==========================

- **.docker/start-env.sh** - this file starts containers, so put there how many containers you need
- **ansible/_inventory** - fill this file with your hosts architecture

#### Optionally

- variables in **.env**
