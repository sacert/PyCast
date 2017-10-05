#!/usr/bin/perl
# indentrees: pretty prints sexp trees taking into consideration max width
# Anoop Sarkar <anoop at linc.cis.upenn.edu>

use Getopt::Std;
my %Options;
getopts('m:', \%Options);
my $maxtrim = 40;
if (defined $Options{'m'}) {
    $maxtrim = $Options{'m'};
}

$usemaxtrim = 1;
$printnl = 1;

while (<>) {
  chomp;
  next if (/^\#/);
  @chars = split('', $_);
  @indent = (); $sz = $#chars+1;
  $prevchar = '';
  while (defined ($c = shift(@chars))) {
    if (($c eq ')') and ($prevchar ne '\\')) { 
      $out = "$c";
      $c = shift(@chars);
      while (($c eq ')') or ($c eq ' ')) { 
        if ($c eq ')') { pop(@indent); }
        $out .= $c if ($c ne ' ');
        $c = shift(@chars);
      }
      if ($c eq '(') { $printnl = 0; }
      unshift(@chars, $c);
      print "$out\n"; 
      $indent = pop(@indent);
      print ' ' x $indent; 
      $j = $indent;
      next;
    }
    if (($c eq '(') and ($prevchar ne '\\')) { 
	if ($printnl and $usemaxtrim and ($j > $maxtrim)) {
	    print "\n";
	    $indent = pop(@indent);
	    push(@indent, $indent);
	    $indent += 2;
	    print ' ' x $indent;
	    $j = $indent;
	}
	push(@indent, $j); 
    }
    $printnl = 1;
    $j++;
    print $c;
    $prevchar = $c;
  }
  print "\n";  
}
