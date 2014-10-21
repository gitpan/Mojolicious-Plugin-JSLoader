#!/usr/bin/env perl

use Mojolicious::Lite;

use Test::More;
use Test::Mojo;

use lib 'lib';
use lib '../lib';

use_ok 'Mojolicious::Plugin::JSLoader';

## Webapp START

plugin('JSLoader');

any '/'      => sub { shift->render( 'default' ) };
any '/hello' => sub {
    my $self = shift;

    $self->js_load( <<'JS', {no_file => 1} );
    $(document).ready(function(){ alert('test') });
JS
    $self->render( 'default' );
};

## Webapp END

my $t = Test::Mojo->new;

my $base_check  = qq~<script type="text/javascript">alert('default');</script>
<script type="text/javascript" src="js_file.js"></script>~;
my $hello_check = q!<script type="text/javascript">    $(document).ready(function(){ alert('test') });
</script>
<script type="text/javascript">alert('default');</script>
<script type="text/javascript" src="js_file.js"></script>!;

$t->get_ok( '/' )->status_is( 200 )->content_is( $base_check );
$t->get_ok( '/hello' )->status_is( 200 )->content_is( $hello_check );

done_testing();

__DATA__
@@ default.html.ep
% js_load( "alert('default');", {no_file => 1} );
% js_load( 'js_file.js' );
