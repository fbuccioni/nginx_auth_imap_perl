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
        *get_conn_data=shift();

        my ($user, $pass) = ($r->header_in('Auth-User'), $r->header_in('Auth-Pass'));
        my ($user_at_domain, $domain);
        my $has_auth = $user && $pass;

        if($has_auth) {
            $user_at_domain = $r->header_in('Auth-User');
        } else {
            $user_at_domain = $r->header_in('Auth-SMTP-To');
            $user_at_domain =~ s/^.*?<(.*?)>.*$/$1/g;
        }

        $domain  = (split(/@/, $user_at_domain))[1];
        
        my ($host, $port, $type, $authmech) = get_conn_data($domain, $r);

        if (  defined $host
              && (
                    !$has_auth
                    || auth(
                          $user
                        , $pass
                        , $host
                        , $port
                        , $type
                        , $authmech
                   )
              )
        ) {
            $r->header_out("Auth-Status", "OK") ;
            $r->header_out("Auth-Server", $host);
            $r->header_out("Auth-Port", (($r->header_in('Auth-Protocol') eq 'smtp') ? 25 : $port));
            $r->header_out("Auth-User",$user);
            $r->header_out("Auth-Pass",$pass);
        } else {
            $r->header_out(
                            "Auth-Status"
                            , ($has_auth)
                               ? "Authentication failed"
                               : "Relay access denied"
            ) ;
        }
   
        $r->send_http_header("text/html");
   
        return OK;
    }

1;
__END__
