nginx_auth_imap_perl
====================

An nginx perl module to authenticate mail proxy to multiple IMAP servers.

This module was created with the idea of deliver mail to an internal VPS using 
nginx as mail proxy. For now the module depends in a static file with the list 
of IMAP hosts per domain, the location is `/etc/nginx/mail_proxy` you can edit
this.


Installation
------------
Follow the instructions from the [Nginx wiki]( http://wiki.nginx.org/ImapAuthenticateWithEmbeddedPerlScript)
but use this module instead the module in the docs.

After that you have to create the `/etc/nginx/mail_proxy` file, this file is
a space/tab separated file.

    #domain   	  host	   port  type         authmech
    #--------------------------------------------------
    example.io   0.0.0.0   993   starttls     cram-md5
    hello.io     1.1.1.1   143   ssl          login
    nobody.io    2.2.2.2   143   plain        plain


TODO
----

+ Automatic detection of configdir for mail_proxy file
+ Reuse connections


* * * 
**Your help is important** if you have fixes or good ideas, just let me know.
