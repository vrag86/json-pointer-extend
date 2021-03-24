#!/usr/bin/env perl

use utf8;
use strict;
use warnings;
use lib 'lib';

use Test::More 'no_plan';

use_ok('JSON::Pointer::Extend');

my $json_pointer = JSON::Pointer::Extend->new();
isa_ok($json_pointer, 'JSON::Pointer::Extend');

my $document = {
    'seat'  => {
        'name'  => 'Место 1',
    },
    'prices'    => [
        {
            'name'  => 'price0',
        },
        {
            'name'  => 'price1',
        },
        {
            'name'  => 'price2',
        },
    ],
    'arr'   => [qw/1 2 3/],
};

my $pointer = {
    '/seat/name' => \&cb1,
    '/prices/*/name' => \&cb2,
    '/arr/*' => \&cb3,
};

$json_pointer->document($document);
$json_pointer->pointer($pointer);

$json_pointer->process();

sub cb1 {
    my ($val) = @_;
    is($val, 'Место 1');
}

sub cb2 {
    my ($val) = @_;
    like($val, qr/price0|price1|price2/);
}

sub cb3 {
    my ($val) = @_;
    like($val, qr/[123]/);
}
