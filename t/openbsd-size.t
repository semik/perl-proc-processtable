# Test size attribute on OpenBSD
# Added by Joelle Maslak <jmaslak@antelope.net>, used bugfix-51470 for
# outline.

use warnings;
use Test::More;
use Data::Dumper;

BEGIN {
  if ( $^O ne 'openbsd' ) {
    plan skip_all => 'OpenBSD-specific tests';
  }

  use_ok('Proc::ProcessTable');
}

SKIP: {
  $0 = "PROC_PROCESSTABLE_TEST_CMD";
  sleep(1);

  skip 'Cannot set process name', 1
    unless ( `ps hwwp $$` =~ /PROC_PROCESSTABLE_TEST_CMD/ );

  $SIG{CHLD} = 'IGNORE';

  my $pid = fork;
  die "cannot fork" unless defined $pid;

  if ( $pid == 0 ) {
    #child
    sleep 10000;
  } else {
    #main
    sleep 1;
    diag "process: " . `ps -lp $pid `;

    my $pstmp = `ps -p $pid -o vsz`;
    my (@lines) = split '\n', $pstmp;
    my $ps_vsize = $lines[1] * 1024;

    my $t   = Proc::ProcessTable->new;
    my ($p) = grep { $_->{pid} == $pid } @{ $t->table };
    is( $p->{size}, $ps_vsize, "Process size = ps vsz" );
    diag "process info: " . Dumper($p);
    kill 9, $pid;
  }
}
done_testing();

