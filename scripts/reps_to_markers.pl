#!/usr/bin/perl
use JSON;
# use DDP;

# my $repsjson = do {
#     local $/ = undef;
#     open my $fh, "<", "-"
#         or die "could not open stdin: $!";
#     <$fh>;
# };

my $repsjson = join("", <STDIN>);
$repsjson =~ s/^\xEF\xBB\xBF//; # remove BOM
my $repshash = JSON->new->decode($repsjson);
my $reps     = $repshash->{repeaters};

my $lon_lat_cache;

my @wanted = split(/:/, $ENV{DUMP_REPS});

foreach my $rep (sort keys %{$reps}) {
  my $r = $reps->{$rep};

  # warn "$r->{callsign} skip bad name.\n" and
  delete $reps->{$rep} and next unless ($r->{callsign} =~ /^LZ/);
  # warn "$r->{callsign} skip disabled.\n" and
  delete $reps->{$rep} and next if ($r->{disabled} == JSON::true);
  # warn "$r->{callsign} skip unwanted.\n" and
  delete $reps->{$rep} and next unless grep (/^$r->{loc}$/i, @wanted);

  delete $r->{coverage};
  $r->{id}      = 'R-' . delete $r->{callsign};
  $r->{updated} = delete $r->{recordUpdated};
  $r->{updated} =~ s/T.*$//g;
  delete $r->{recordCreated};

  $r->{type}        = 'feature';
  foreach my $rm (keys %{$r->{mode}}) {
    $r->{details}->{mode} .= "$rm, " if ($r->{mode}->{$rm} == JSON::true);
  }
  $r->{details}->{mode} =~ s/, $//;
  my $mod = 'nfm';
  if (!$r->{mode}->{analog} or $r->{mode}->{analog} != JSON::true) {
    if    ($r->{mode}->{dmr} == JSON::true)    { $mod = 'dmr' }
    elsif ($r->{mode}->{dstar} == JSON::true)  { $mod = 'dstar' }
    elsif ($r->{mode}->{fusion} == JSON::true) { $mod = 'ysf' }
  }

  $r->{mmode} = $mod;
  $r->{mode}  = 'Reps-BG';
  $r->{info}  = join '<br>', @{$r->{info}};
  $r->{info} =~ s/onclick='[^']+'//gi;
  $r->{info} =~ s/\s+>/>/g;
  $r->{info} =~ s/<\s+/</g;
  $r->{info} =~ s/<a[^>]*href='[#]?'[^>]?>([^<]+)<\/a>/$1/gi;
  $r->{comment} = delete $r->{info};
  delete $r->{comment} if (!$r->{comment} or $r->{comment} eq '');
  # $r->{loc} .= ', ' . $r->{locExtra} if ($r->{locExtra} and $r->{locExtra} ne '');
  delete $r->{locExtra};

  my $ll = sprintf("%.4f", $r->{lon}) . '|' . sprintf("%.4f", $r->{lat});
  if ($lon_lat_cache->{$ll}) {
    warn "duplicate location for $r->{id} ($ll), $lon_lat_cache->{$ll} is already there.\n";
    $r->{lon} += 0.0005;
    # $r->{lat} += 0.0001;
  }
  $ll = sprintf("%.4f", $r->{lon}) . '|' . sprintf("%.4f", $r->{lat});
  $lon_lat_cache->{$ll} = $r->{id};

  $r->{freq} = sprintf("%d", $r->{rx} * 1000 * 1000)+0;
  $r->{symbol} = '&#9094;';
  $r->{color}  = '#60274E';

  for my $k (keys %{$r}) {
    next
      if ($k eq 'id'
      or $k eq 'lat'
      or $k eq 'lon'
      or $k eq 'freq'
      or $k eq 'altitude'
      or $k eq 'rx'
      or $k eq 'tx'
      or $k eq 'comment'
      or $k eq 'mmode'
      or $k eq 'mode'
      or $k eq 'type'
      or $k eq 'updated'
      or $k eq 'symbol'
      or $k eq 'color');
    next if ($k =~ /^details$/);
    $r->{details}->{$k} = delete $r->{$k};
  } ## end for my $k (keys %{$r})
  warn "$r->{id} added.\n";
} ## end foreach my $rep (sort keys ...)

print "{}\n" and exit unless (scalar keys (%{$reps}) > 0);

my $repsjson = JSON->new->encode($reps);
print $repsjson;
