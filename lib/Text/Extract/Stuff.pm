package Text::Extract::Stuff;

use 5.008006;
use strict;
use warnings;
use HTML::SimpleLinkExtor;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = (
	'all' => [ qw(
		Extract_Email Extract_Html_Comment Extract_Html_Form Extract_Html_Hidden Extract_Html_Links Extract_Html_Script Extract_Html_Title Extract_Ipaddress Extract_Phone
	) ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.03';
$VERSION = eval $VERSION;

$|=1;

sub Extract_Email{
	my @data = @_;
	my $data = join(" ",@data);
	$data =~ s/\n|\r|<br>//ig;
	my @res;

	while ($data =~ m/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/ig){
		push @res,$&;
	}

	return @res;
}

sub Extract_Html_Comment{
	my @data = @_;
	my $data = join(" ",@data);
	$data =~ s/\n|\r|<br>//ig;
	my @res;

	while ($data =~ m/<!--(.*?)-->/ig){
		my $comment = $1; $comment =~ s/^\s+|\s+$//g;
		push @res,$comment;
	}

	return @res;
}

sub Extract_Html_Form{
	my @data = @_;
	my $data = join(" ",@data);
	$data =~ s/\n|\r|<br>|\s\s|\t//ig;
	my @res;

	while ($data =~ m/<form (.*?)<\/form>/ig){
		push @res,"<form $1</form>";
	}

	return @res;
}

sub Extract_Html_Hidden{
	my @data = @_;
	my $data = join(" ",@data);
	$data =~ s/\n|\r|<br>|\s\s|\t//ig;
	my @html;

	# HTML <[^<]+?>
	while ($data =~ m/<[^<]+?>/ig){
		push @html,$&;
	}

	my @res;
	foreach (@html){
		if ($_ =~ m/^<input type=\"hidden\" name=\"(.*?)\">$|^<input type=\'hidden\' name=\'(.*?)\'>$/ig){
			my $x = $1; $x =~ s/"|'//g;
			push @res,"name=$x";
		}
		if ($_ =~ m/^<input type=\"hidden\" name=\"(.*?)\" value=\"(.*?)\">$|^<input type=\'hidden\' name=\'(.*?)\' value=\'(.*?)\'>$/ig){
			my $x = $1; my $y = $2; $x =~ s/"|'//g; $y =~ s/"|'//g;
			push @res,"name=$x;value=$y";
		}
	}

	return @res;
}

sub Extract_Html_Links{
	my @data = @_;
	my $data = join(" ",@data);
	$data =~ s/\n|\r|<br>//ig;

	my $extor = HTML::SimpleLinkExtor->new();
	$extor->parse($data);
	my @res = $extor->a;

	return @res;
}

sub Extract_Html_Script{
	my @data = @_;
	my $data = join(" ",@data);
	$data =~ s/\n|\r|<br>|\s\s|\t//ig;
	my @res;

	while ($data =~ m/<script>(.*?)<\/script>/ig){
		push @res,"<script>$1<\/script>";
	}

	while ($data =~ m/<script language=\"javascript\">(.*?)<\/script>/ig){
		push @res,"<script language=\"javascript\">$1<\/script>";
	}

	while ($data =~ m/<script language=\"javascript\" type=\"text\/javascript\">(.*?)<\/script>/ig){
		push @res,"<script language=\"javascript\" type=\"text\/javascript\">$1<\/script>";
	}

	while ($data =~ m/<script type=\"text\/javascript\">(.*?)<\/script>/ig){
		push @res,"<script type=\"text\/javascript\">$1<\/script>";
	}

	while ($data =~ m/<script type=\"text\/javascript\" (.*?)>(.*?)<\/script>/ig){
		push @res,"<script type=\"text\/javascript\" $1>$2<\/script>";
	}

	while ($data =~ m/<script src=\"(.*?)\" type=\"text\/javascript\">(.*?)<\/script>/ig){
		push @res,"<script src=\"$1\" type=\"text\/javascript\">$2<\/script>";
	}

	return @res;
}

sub Extract_Html_Title{
	my @data = @_;
	my $data = join(" ",@data);
	$data =~ s/\n|\r|<br>//ig;
	my @res;

	while ($data =~ m/<title>(.*?)<\/title>/ig){
		my $title = $1; $title =~ s/^\s+|\s+$//g;
		push @res,$title;
	}

	return @res;
}

sub Extract_Ipaddress{
	my @data = @_;
	my $data = join(" ",@data);
	$data =~ s/\n|\r|<br>//ig;
	my @res;

	while ($data =~ m/([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])/g){
		push @res,"$1.$2.$3.$4";
	}

	return @res;
}

sub Extract_Phone{
	my (@data,$phone_mask) = @_;
	my $data = join(" ",@data);
	$data =~ s/\n|\r|<br>//ig;
	$phone_mask = 'x-xxx-xxx-xxxx' if !$phone_mask;

	my @res;

	$phone_mask =~ s/\-/\\-/g;
	$phone_mask =~ s/\(/\\(/g;
	$phone_mask =~ s/\)/\\)/g;
	$phone_mask =~ s/\./\\./g;
	$phone_mask =~ s/\+/\\+/g;
	$phone_mask =~ s/\//\\\//g;
	$phone_mask =~ s/x/\\d/g;

	while ($data =~ m/ $phone_mask/g){
		my $phone = $&;
		$phone =~ s/^\s|\s$//g;
		push @res,$phone;
	}

	return @res;
}

1;
__END__

=head1 NAME

Text::Extract::Stuff - Perl module to extract stuff from text. 

=head1 SYNOPSIS

  use Text::Extract::Stuff qw( :all );

  my $txtfile = $ARGV[0];
  die "text file?!\n" if !$textfile;

  my @text;
  open(TEXT, "<$txtfile") || die "Error: cannot open the text file: $!\n";
  chomp (@text = <TEXT>);
  close (TEXT);

  my @res = Extract_Email(@text);
  print "\nEmail Address :\n";
  print "$_\n" for @res;

  @res = Extract_Html_Links(@text);
  print "\nHtml Links :\n";
  print "$_\n" for @res;

  @res = Extract_Html_Title(@text);
  print "\nHtml Title :\n";
  print "$_\n" for @res;

  @res = Extract_Html_Comment(@text);
  print "\nHtml Comment :\n";
  print "$_\n" for @res;

  @res = Extract_Phone(@text,"x-xxx-xxx-xxxx");
  print "\nPhone Address :\n";
  print "$_\n" for @res;

  @res = Extract_Ipaddress(@text);
  print "\nIp Address :\n";
  print "$_\n" for @res;

  @res = Extract_Html_Script(@text);
  print "\nHtml Script :\n";
  print "$_\n" for @res;

  @res = Extract_Html_Form(@text);
  print "\nHtml Form :\n";
  print "$_\n" for @res;

  @res = Extract_Html_Hidden(@text);
  print "\nHtml Hidden Form Field :\n";
  print "$_\n" for @res;

  exit(0);

=head1 DESCRIPTION

Text::Extract::Stuff - Perl module to extract stuff from text.

This module allows to extract email address, html comment, html form, html hidden form field, html links, html title, ip address, phone number and html script from text.

Every function returns an array with data extracted like in the example above.

Note: using Extract_Phone function you must specify a phone mask. e.g. x-xxx-xxx-xxxx

=head1 SEE ALSO

File::Extract, HTML::Extract, HTML::SimpleLinkExtor, Net::IP::Extract

=head1 AUTHOR

Matteo Cantoni, E<lt>matteo.cantoni@nothink.org<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Matteo Cantoni

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
