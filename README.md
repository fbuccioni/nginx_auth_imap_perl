nginx_auth_imap_perl
====================

An nginx perl module to authenticate mail proxy to multiple IMAP servers.

This module was created with the idea of deliver mail to an internal VPS
using nginx as mail proxy. You can use [Perl DBI](http://http://dbi.perl.org/)
(this mean, almost any database like MySQL, PostgreSQL, LDAP, SQLite and
[much more](https://metacpan.org/search?p=2&q=DBD%3A%3A)) or use a plain
text file, to handle the IMAP servers and his domains.


Installation
------------

- Install dependencies.

        perl -MCPAN -e 'install Mail::IMAPClient'
        
    **IMPORTANT:** If you want to use a DBI interface, you have to install
    the DBI Database Driver (DBD), almost all DBDs are in your package
    manager (if you are using a unix-alike OS).


- Clone the code from github.

        git clone git@github.com/falcacibar/nginx_auth_imap_perl

- Copy the mailauth folder to some directory (any, this is just an example).

        mkdir /usr/local/lib/perl5
        cp -r nginx_auth_imap_perl/mailauth /usr/local/lib/perl5


Configuration
-------------

- Include the module in the http server, the module could be `mailauth/DBI.pm` if you want to use a DBI Database, or `mailauth/plaintext.pm`for plain text database.
 
        http {
            ...
                perl_modules /usr/local/lib/perl5;
	            perl_require mailauth/DBI.pm;
            ...
        }
   
- Create the auth url using the module, in your `server {` section of your
  domain:

    If you are using the plaintext db
    
            set $mailauth_db_path   "/etc/nginx/mail_proxy";
                    
    If you are using DBI (MySQL example)
    
            set $mailauth_dbi_dsn    "DBI:mysql:database=mail";
            set $mailauth_dbi_user   "mail";
            set $mailauth_dbi_pass   "secret";
            set $mailauth_dbi_query  "
                                        SELECT      host, port, type, authmech
                                        FROM        imap_servers
                                        WHERE       name = ? 
                                                    AND d.enabled = 1;
             ";    


    Whatever you choose, just don't forget to add
    
            perl mailauth::DBI::handler;

- If you choose the plaintext database this file is the space/tab separated
  file format.

        #domain         host	   port  type         authmech
        #--------------------------------------------------
        example.io   0.0.0.0   993   starttls     cram-md5
        hello.io     1.1.1.1   143   ssl          login
        nobody.io    2.2.2.2   143   plain        plain

- Finally we use our auth server, in the `mail {` section of your nginx conf

        mail {
            ...
            auth_http                 127.0.0.1:80/auth;
            ...
        }

TODO
----

+ Reuse connections
+ GNU GPL Liscense in files

* * * 
**Your help is important** if you have fixes or good ideas, just let me know.
