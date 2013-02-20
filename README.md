# My base boxes

This repository contains Veewee box definitions. They are intented to be used
with `vagrant`.

* `centos57-x86_64` - CentOS 5.7 64bits.  
  Contains ruby-1.9.3-p385 (managed via rvm), chef and puppet.
* `ubuntu-1210-i386` - Ubuntu 12.10 32bits.  
  Contains ruby 1.9.1 (managed via apt), chef and puppet.

## How to build the boxes

    vagrant basebox build <box-name>
    # wait
    vagrant basebox export <box-name>

## How to use the box

  * Put the box in your `Vagrantfile`

