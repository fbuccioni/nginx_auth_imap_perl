package mailauth::plaintext;
    use strict;
    use warnings;

    use lib '../';
    use mailauth;

    sub get_conn_data {
        my $domain       = shift;
        my $r            = shift;
        my $domain_found = 0;
        my @data;
 
        if($domain) {
            open(CONF, "< ".$r->variable('mailauth_db_path'));
            while (my($line)=<CONF>) {
                $line =~ s/#.*$//;
                $line =~ s/\s$//g;
                $line =~ s/^\s//g;
            
                if($line) {
                    @data = split(/\s+/, $line);
                    if (scalar(@data) > 1 && $data[0] eq $domain ) {
                        $domain_found = 1;
                        shift(@data);
                        last;
                    }
                }
            }
            close(CONF);
        }
 
        return $domain_found 
                   ? @data
                   : (undef, undef, undef, undef)
        ;
    };

    sub handler {
        my $r = shift;
        return mailauth::handler($r, \&get_conn_data);
    }
1;
__END__
