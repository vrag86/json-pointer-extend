package JSON::Pointer::Extend;

use utf8;
use strict;
use warnings;

use JSON::Pointer;
use Carp qw();

our $VERSION = '0.01';

sub new {
    my ($class, %opt) = @_;
    my $self = {};
    bless $self, $class;

    $self->pointer(delete $opt{'-pointer'});
    $self->document(delete $opt{'-document'});

    return $self;
}

sub process {
    my ($self) = @_;
    my $pointer = $self->pointer // Carp::croak("'pointer' not defined");

    for my $key (keys %$pointer) {
        $self->_recursive_process($self->document, $key, $pointer->{$key});
    }
    return 1;
}

sub _recursive_process {
    my ($self, $document, $pointer, $cb) = @_;

    if (not $pointer) {
        $cb->($document);
    }
    elsif ($pointer =~ /(.+?)\/\*(.+)?/) {
        my $arr = JSON::Pointer->get($document, $1);
        my $tail = $2;
        if (ref($arr) ne 'ARRAY') {
            Carp::croak("Path '$pointer' not array");
        }
        for my $el (@$arr) {
            $self->_recursive_process($el, $tail, $cb);
        }
    }
    else {
        $cb->(JSON::Pointer->get($document, $pointer));
    }
}

############################### GET/SET METHODS ##############################

sub document {
    if (scalar(@_) > 1) {
        $_[0]->{'document'} = $_[1];
    }
    return $_[0]->{'document'};
}

sub pointer {
    if (scalar(@_) > 1) {
        $_[0]->{'pointer'} = $_[1];
    }
    return $_[0]->{'pointer'};
}

1;
