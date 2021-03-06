#!/usr/bin/perl -wT
package RumorGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_rumor );


###############################################################################

=head1 NAME

    RumorGenerator - used to generate Rumors

=head1 SYNOPSIS

    use RumorGenerator;
    my $rumor1=RumorGenerator::create_rumor();
    my $rumor2=RumorGenerator::create_rumor($parameters);

=cut

###############################################################################


use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw( rand_from_array roll_from_array d parse_object );
use List::Util 'shuffle', 'min', 'max';
use NPCGenerator;
use POSIX;
use Template;
use version;
use XML::Simple;

my $xml = XML::Simple->new();
local $ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::Parser';

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by RumorGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/rumors.xml>

=back

=head1 INTERFACE 


=cut

###############################################################################

my $xml_data      = $xml->XMLin( "xml/data.xml",    ForceContent => 1, ForceArray => ['option'] );
my $rumor_data    = $xml->XMLin( "xml/rumors.xml",  ForceContent => 1, ForceArray => ['option'] );

###############################################################################

=head2 Core Methods

The following methods are used to create the core of the rumor structure.

=head3 create_rumor()

This method is used to create a simple rumor with nothing more than:

=over

=item * a seed

=back

=cut

###############################################################################
sub create_rumor {
    my ($params) = @_;
    my $rumor = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $rumor->{$key} = $params->{$key};
        }
    }

    if ( !defined $rumor->{'seed'} ) {
        $rumor->{'seed'} = GenericGenerator::set_seed();
    }
    GenericGenerator::set_seed( $rumor->{'seed'} );

    GenericGenerator::select_features($rumor,$rumor_data);

    foreach my $npctitle (qw(believer source culprit victim)){
        $rumor->{$npctitle}=NPCGenerator::create_npc()->{'name'} if (!defined $rumor->{$npctitle});
    }

    GenericGenerator::parse_template($rumor,'belief') if (defined $rumor->{'belief'});
    GenericGenerator::parse_template($rumor,'heardit') if (defined $rumor->{'heardit'});

    GenericGenerator::parse_template($rumor, 'template');
    append_extras($rumor);
    return $rumor;
}



###############################################################################

=head2 append_extras()

append non-interpolated features to $rumor->template()

=cut

###############################################################################
sub append_extras {
    my ($rumor) = @_;
    if (defined $rumor->{'heardit'}){
       $rumor->{'template'}=$rumor->{'heardit'}." ".$rumor->{'template'};
    }

    $rumor->{'template'}=ucfirst $rumor->{'template'};
    
    if (defined $rumor->{'belief'}){
       $rumor->{'template'}=$rumor->{'template'}." ".$rumor->{'belief'};
    }
    
    return $rumor;
}

1;

__END__


=head1 AUTHOR

Jesse Morgan (morgajel)  C<< <morgajel@gmail.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013, Jesse Morgan (morgajel) C<< <morgajel@gmail.com> >>. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation version 2
of the License.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=head1 DISCLAIMER OF WARRANTY

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=cut
