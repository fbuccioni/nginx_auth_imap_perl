package mailauth;
    use strict;
    use warnings;

    use nginx;
    use Mail::IMAPClient;

    sub auth {
        my $user     = shift;
        my $pass     = shift;
        my $host     = shift;
        my $port     = shift;
	my $type     = shift;
        my $authmech = shift; 
        my ($imap, $connected);

	#open(LOG, '>> /etc/nginx/auth.log');
        $imap = Mail::IMAPClient->new(
             Server          => $host
             , User          => $user
             , Password      => $pass
	     , Port          => $port
             , Starttls      => (lc($type) eq 'starttls')
             , Ssl           => (lc($type) eq 'ssl')
             , Authmechanism => uc($authmech)
             #, Debug         => 1
             #, Debug_fh      => \*LOG
        );

	$imap->disconnect() if($connected = defined($imap));
	return $connected;
    }
   
    sub handler {
        my $r=shift; 
        my ($domain, $host, $port, $type, $authmech);
        my ($user, $pass) = ($r->header_in('Auth-User'), $r->header_in('Auth-Pass'));
	my $auth_domain  = (split(/@/, $user))[1];
        my $domain_found = 0; 

	if($auth_domain) {
 	     open(CONF, "< /etc/nginx/mail_proxy");
             while (my($line)=<CONF>) {
                 $line =~ s/#.*$//;
                 $line =~ s/\s$//g;
                 $line =~ s/^\s//g;
         
                 if($line) {
                     ($domain, $host, $port, $type, $authmech) = split(/\s+/, $line);
                     if ($domain eq $auth_domain ) {
                         $domain_found = 1;
                         last;
                     }
                 }
             }
             close(CONF);
        }

        if (  $domain_found
              && auth(
                      $user
                    , $pass
                    , $host
		    , $port
                    , $type
                    , $authmech
             )
        ) {
            $r->header_out("Auth-Status", "OK") ;
            $r->header_out("Auth-Server", $host);
            $r->header_out("Auth-Port", (($r->header_in('Auth-Protocol') eq 'smtp') ? 25 : $port));
            $r->header_out("Auth-User",$user);
            $r->header_out("Auth-Pass",$pass);
        } else {
            $r->header_out("Auth-Status", "Invalid login or password") ;
        }
   
        $r->send_http_header("text/html");
   
        return OK;
    }

1;
__END__
