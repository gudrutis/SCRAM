#____________________________________________________________________ 
# File: PluginCore.pm
#____________________________________________________________________ 
#  
# Author: Shaun Ashby <Shaun.Ashby@cern.ch>
# Update: 2004-04-29 16:07:07+0200
# Revision: $Id: PluginCore.pm,v 1.4 2007/12/14 09:03:50 muzaffar Exp $ 
#
# Copyright: 2004 (C) Shaun Ashby
#
#--------------------------------------------------------------------
package BuildSystem::Template::Plugins::PluginCore;
use vars qw( @ISA );
use Exporter;
@ISA=qw(Exporter);

##################
sub load()
   ###############################################################
   # load()                                                      #
   ###############################################################
   # modified : Thu Feb 26 12:36:07 2004 / SFA                   #
   # params   :                                                  #
   #          :                                                  #
   # function :                                                  #
   #          :                                                  #
   ###############################################################
   {
   my ($class, $context) = @_;
   return $class;
   }

sub new()
   ###############################################################
   # new()                                                       #
   ###############################################################
   # modified : Thu Apr 29 16:07:56 2004 / SFA                   #
   # params   :                                                  #
   #          :                                                  #
   # function :                                                  #
   #          :                                                  #
   ###############################################################
   {
   my $proto=shift;
   my $class=ref($proto) || $proto;
   my $self =
      {
      _CONTEXT => shift
      };
   
   bless $self,$class;
   
   # Store data:
   $self->{_BRANCH} = $self->{_CONTEXT}->stash()->get('branch');
   
   $self->{_META} = $self->{_BRANCH}->branchdata();
   
   # Set the most commonly-used features:
   $self->{_CONTEXT}->stash()->set('safepath', $self->{_BRANCH}->safepath());
   $self->{_CONTEXT}->stash()->set('path', $self->{_BRANCH}->path());
   $self->{_CONTEXT}->stash()->set('suffix', $self->{_BRANCH}->suffix());
   $self->{_CONTEXT}->stash()->set('class', $self->{_BRANCH}->class());
   $self->{_CONTEXT}->stash()->set('classdir', $self->{_BRANCH}->classdir());
   $self->{_CONTEXT}->stash()->set('parent', $self->{_BRANCH}->parent());

   return $self;
   }

sub variables()
   {
   my $self=shift;
   return "";
   }

sub branchdata()
   {
   my $self=shift;
   return $self->{_BRANCH};
   }

sub name()
   {
   my $self=shift;
   return $self->{_BRANCH}->name();
   }

sub publictype()
   {
   my $self=shift;
   return $self->{_BRANCH}->publictype(@_);
   }

sub productname()
   {
   my $self=shift;
   (defined $self->{_THISCOREPRODUCT}) ? return $self->{_THISCOREPRODUCT}->name()
      : return "";
   }

sub productfiles()
   {
   my $self=shift;
   (defined $self->{_THISCOREPRODUCT}) ? return join(" ",@{$self->{_THISCOREPRODUCT}{FILES}})
      : return "";
   }

sub producttype()
   {
   my $self=shift;
   (defined $self->{_THISCOREPRODUCT}) ? return $self->{_THISCOREPRODUCT}{TYPE}
      : return "";
   }

sub flagsdata ()
   {
   my $self=shift;
   my $flag=shift;
   my $allflags = $self->allflags();
   if (exists $allflags->{$flag}){return $allflags->{$flag};}
   return [];
   }
   
sub flags()
   {
   my $self=shift;
   my ($flag)=@_;
   my $allflags = $self->allflags();
   if (exists $allflags->{$flag})
      {
      return join(" ",@{$allflags->{$flag}});
      }
   return "";
   }

sub allflags()
   {
   my $self=shift;
   if (exists $self->{FLAG_CACHE})
      {
      return $self->{FLAG_CACHE};
      }
   $self->{FLAG_CACHE}={};
   foreach my $t ($self->{_META},$self->{_THISCOREPRODUCT})
      {
      if (defined $t && exists $t->{content}{FLAGS})
         {
	 foreach my $f (keys %{$t->{content}{FLAGS}})
	    {
	    if (!exists $self->{FLAG_CACHE}{$f})
	       {
	       $self->{FLAG_CACHE}{$f}=[];
	       }
	    foreach my $fv (@{$t->{content}{FLAGS}{$f}})
	       {
	       push @{$self->{FLAG_CACHE}{$f}},($f eq "CPPDEFINES") ? "-D$fv":$fv;
	       }
	    }
	 if ((exists $t->{content}{ARCH}) &&
	     (exists $t->{content}{ARCH}{$ENV{SCRAM_ARCH}}) &&
	     (exists $t->{content}{ARCH}{$ENV{SCRAM_ARCH}}{FLAGS}))
	    {
	    foreach my $f (keys %{$t->{content}{ARCH}{$ENV{SCRAM_ARCH}}{FLAGS}})
	       {
	       if (!exists $self->{FLAG_CACHE}{$f})
	          {
	          $self->{FLAG_CACHE}{$f}=[];
	          }
	       foreach my $fv (@{$t->{content}{ARCH}{$ENV{SCRAM_ARCH}}{FLAGS}{$f}})
	          {
	          push @{$self->{FLAG_CACHE}{$f}},($f eq "CPPDEFINES") ? "-D$fv":$fv;
	          }
	       }
	    }
	 }
      }
      return $self->{FLAG_CACHE};
   }

sub allscramstores()
   {
   my $self=shift;
   return $self->{_BRANCH}->productstore();
   }

sub value ()
   {
   my $self=shift;
   my $tag=shift;
   my $data=shift;
   my @dlist=();
   if(defined $data){push @dlist,$data;}
   else
      {
      if ((defined $self->{_META}) && (exists $self->{_META}{content}))
         {push @dlist,$self->{_META}{content};}
      if ((defined $self->{_THISCOREPRODUCT}) && (exists $self->{_THISCOREPRODUCT}{content}))
         {push @dlist,$self->{_THISCOREPRODUCT}{content};}
      }
   my $ret=[];
   foreach my $t (@dlist)
      {
      if (defined $t)
         {
         if (exists $t->{$tag})
            {
            foreach my $d (@{$t->{$tag}})
               {
	       push @$ret,$d;
	       }
            }
         if ((exists  $t->{ARCH}{$ENV{SCRAM_ARCH}}) && (exists $t->{ARCH}{$ENV{SCRAM_ARCH}}{$tag}))
            {
            foreach my $d (@{$t->{ARCH}{$ENV{SCRAM_ARCH}}{$tag}})
               {
	       push @$ret,$d;
	       }
	    }
         }
      }
   if(scalar(@$ret)){return $ret;}
   return "";
   }
   
sub data()
   {
   my $self=shift;
   my ($tag)=@_;   
   return $self->{_META}->{content}{$tag}, if (defined($self->{_META}->{content}));
   }

sub safesubdirs()
   {
   my $self=shift;
   return $self->{_BRANCH}->safesubdirs(), if (defined($self->{_BRANCH}));
   }

sub scramprojectbases()
   {
   my $self=shift;
   return "";
   # This is needed at project level only:
   #return $self->{_BRANCH}->scramprojectbases(), if (defined($self->{_BRANCH}));
   }

sub bfdeps()
   {
   my $self=shift;
   my $bf={};

   # BuildFiles the current product depends on:
   if (defined($self->{_BRANCH}))
      {
      my $metabf=$self->{_BRANCH}->metabf();
      map
	 {
	 $bf->{$_}=1;
	 } @$metabf;
      }

   return $bf;
   }
   
sub pkdeps()
   {
   my $self=shift;

   # Store dependent package rules:
   $self->{_PACKAGE_RULES} = [];
   # Convert the dependent packages into their rules. We must also append/prepend "src"
   # so that we generate the safe path for each dependent package:
   if (defined $self->{_META})
      {
      map
	 {
	 $_ =~ s|/|_|g;
	 push(@{$self->{_PACKAGE_RULES}},'src_'.$_.'_src');
	 } @{$self->{_META}->local_package_deps()};
      return join(" ",@{$self->{_PACKAGE_RULES}});
      }
   else
      {
      return "";
      }
   }

# Build products:
sub buildproducts()
   {
   my $self=shift;
   return $self->{_META}->{content}{BUILDPRODUCTS};
   }

# Set the data for current product object:
sub thisproductdata()
   {
   my $self=shift;
   my ($safename,$type)=@_;
   # The name arg is used to switch to the correct data object
   # _THISCOREPRODUCT points to the Product object:
   $self->{_THISCOREPRODUCT} = $self->{_META}->{content}{BUILDPRODUCTS}{$type}{$safename};
   delete $self->{FLAG_CACHE};
   $self->allflags();
   }

1;
