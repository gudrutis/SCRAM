#____________________________________________________________________ 
# File: ToolCache.pm
#____________________________________________________________________ 
#  
# Author: Shaun Ashby <Shaun.Ashby@cern.ch>
# Update: 2003-10-28 10:14:08+0100
# Revision: $Id: ToolCache.pm,v 1.4.10.1 2008/03/13 12:54:50 muzaffar Exp $ 
#
# Copyright: 2003 (C) Shaun Ashby
#
#--------------------------------------------------------------------
package BuildSystem::ToolCache;
require 5.004;

use Exporter;
@ISA=qw(Exporter);
#
sub new()
   {
   my $proto=shift;
   my $class=ref($proto) || $proto;
   my $self={};
   $self->{SETUP}={};
   bless $self,$class;
   return $self;
   }

sub setup()
   {
   my $self=shift;
   return $self->{SETUP};
   }

sub name()
   {
   my $self = shift;
   # Set the name of the cache file:
   @_ ? $self->{CACHENAME} = shift #
      : $self->{CACHENAME};
   }
   
sub dirty()
   {
   my $self = shift;
   $self->{internal}{dirty}=1;
   }

sub isdirty()
   {
   my $self = shift;
   my $dirty = $self->{internal}{dirty} || 0;
   return $dirty;
   }
   
sub writecache()
   {
   my $self=shift;
   if (exists $self->{internal}{dirty})
      {
      my $file=$self->{CACHENAME};
      delete $self->{internal};
      use Cache::CacheUtilities;
      &Cache::CacheUtilities::write($self,$file);
      }
   }

1;
   
