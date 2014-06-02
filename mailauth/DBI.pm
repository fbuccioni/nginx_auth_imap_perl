package mailauth::DBI;
    use strict;
    use warnings;

    use lib '../';
    use mailauth;

    sub get_conn_data {
        my $domain  = shift;
        my $r       = shift;
        my $data;
 
        if($domain) {
            use DBI;

            my ($dbh, $sth);
            $dbh = DBI->connect(
                                    $r->variable('mailauth_dbi_dsn')
                                    , $r->variable('mailauth_dbi_user')
                                    , $r->variable('mailauth_dbi_pass')
            );

            $sth = $dbh->prepare($r->variable('mailauth_dbi_query'));
            $sth->execute($domain);
            $data = $sth->fetchrow_arrayref();

            $sth->finish();
            $dbh->disconnect();
        }

        return defined($data)
                   ? @{$data}
                   : (undef, undef, undef, undef)
        ;
    };

    sub handler {
        my $r = shift;
        return mailauth::handler($r, \&get_conn_data);
    }

1;
