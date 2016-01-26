# machina
Just a hobby, won’t be big and professional like GNU/Linux.

## How to run
On linux machines:
* `make run`
* done!

For other operating systems, or if you just want to keep your dev environment seperate.
* `vagrant up`
* `vagrant rsync-auto` (As a job or in another terminal)
* `vagrant ssh`
* `cd /vagrant`
* `make run`
* done!

## CPU Feature Error Codes
If your CPU does not support features deemed required by machina then you will see an error message prior to kmain.

The following is a table of possible error codes:

| code | description                    |
|-----:|--------------------------------|
| 0    | multibook magic number not set |
| 1    | CPUID check failed             |
| 2    | Long mode check failed         |
| a    | SSE check failed               |



