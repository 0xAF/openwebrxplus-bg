#!/usr/bin/perl

use JSON;
# use DDP;

my $repsjson = join("", <STDIN>);

my $repshash = JSON->new->decode($repsjson);
my $reps     = $repshash->{repeaters};

my @wanted = split(/:/, $ENV{DUMP_REPS});

my @bookmarks;

foreach my $rep (sort keys %{$reps}) {
  my $r = $reps->{$rep};

  # warn "$r->{callsign} skip bad name.\n" and
  next unless ($r->{callsign} =~ /^LZ/);
  # warn "$r->{callsign} skip disabled.\n" and
  next if ($r->{disabled} == JSON::true);
  # warn "$r->{callsign} skip 2m reps.\n" and
  next if ($r->{rx} > 144 and $r->{rx} < 146);
  # warn "$r->{callsign} skip unwanted.\n" and
  next unless grep (/^$r->{loc}$/i, @wanted);

  my $mod = 'nfm';
  if (!$r->{mode}->{analog} or $r->{mode}->{analog} != JSON::true) {
    if    ($r->{mode}->{dmr} == JSON::true)    { $mod = 'dmr' }
    elsif ($r->{mode}->{dstar} == JSON::true)  { $mod = 'dstar' }
    elsif ($r->{mode}->{fusion} == JSON::true) { $mod = 'ysf' }
  }
  my ($short_name) = ($r->{callsign} =~ /^LZ0(.*)$/);
  push @bookmarks,
    {name => 'IN:' . $short_name, frequency => sprintf("%d", $r->{tx} * 1000 * 1000) + 0, modulation => $mod}
    if ($r->{rx} != $r->{tx});
  push @bookmarks, {name => $r->{callsign}, frequency => sprintf("%d", $r->{rx} * 1000 * 1000) + 0, modulation => $mod};
} ## end foreach my $rep (sort keys ...)

for my $r (0..7) {
  my $in = 145000000 + ($r * 25000);
  push @bookmarks, {name => 'IN:' . $r, frequency => sprintf("%d", $in) + 0, modulation => 'nfm'};
  push @bookmarks, {name => 'R' . $r, frequency => sprintf("%d", $in+600000) + 0, modulation => 'nfm'};
}
for my $r (8..15) {
  my $in = 144400000 + ($r * 25000);
  push @bookmarks, {name => 'IN:' . $r, frequency => sprintf("%d", $in) + 0, modulation => 'nfm'};
  push @bookmarks, {name => 'R' . $r, frequency => sprintf("%d", $in+600000) + 0, modulation => 'nfm'};
}

print "[]" and exit unless ($#bookmarks >= 0);
my $bjson = JSON->new->encode(\@bookmarks);
print $bjson;
