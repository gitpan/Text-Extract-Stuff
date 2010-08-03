use Test::More tests => 1;
BEGIN { use_ok('Text::Extract::Stuff') };

use Text::Extract::Stuff qw ( :all );

my $data = 'matteo.cantoni@nothink.org';

Extract_Email($data);

exit(0);
