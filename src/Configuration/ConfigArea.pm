#
# ConfigArea.pm
#
# Originally Written by Christopher Williams
#
# Description
#
# Interface
# ---------
# new(ActiveConfig)		: A new ConfigArea object
# setup()		        : setup the configuration area
# location([dir])		: set/return the location of the area
# version([version])		: set/return the version of the area
# name([name])			: set/return the name of the area
# store(location)		: store data in file location
# restore(location)		: restore data from file location
# meta()			: return a description string of the area
# addconfigitem(url)		: add a new item to the area
# configitem(@keys)		: return a list of fig items that match
#				  the keys - all if left blank

package Configuration::ConfigArea;
use ActiveDoc::ActiveDoc;
require 5.004;
use Utilities::AddDir;
use ObjectUtilities::ObjectStore;
@ISA=qw(ActiveDoc::ActiveDoc ObjectUtilities::StorableObject);

sub init {
	my $self=shift;
	$self->newparse("init");
	$self->newparse("download");
	$self->newparse("setup");
	$self->addtag("init","project",\&Project_Start,$self,
	\&Project_text,$self,"", $self );
	$self->addurltags("download");
	$self->addtag("download","use",\&Use_download_Start,$self, 
						"", $self, "",$self);
	$self->addurltags("setup");
	$self->addtag("setup","use",\&Use_Start,$self, "", $self, "",$self);
}

sub setup {
	my $self=shift;

	# --- find out the location
	my $location=$self->requestoption("area_location",
		"Please Enter the location of the directory");

	# --- find area directory name , default name projectname_version
	my $name=$self->option("area_name");
	my $vers=$self->version;
	if ( ! defined $name ) {
	  $name=$self->name();
	  $vers=~s/^$name_//;
	  $name=$name."_".$vers;
	}
	$self->location($location."/".$name);

	# --- make a new ActiveStore at the location and add it to the db list
	my $ad=ActiveDoc::ActiveConfig->new($self->location()."/\.SCRAM");

	# make a new store handler
	my $parentconfig=$self->config;
	$self->config(Configuration::ConfigureStore->new());
	$self->config()->db("local",$ad);
	$self->config()->db("parent",$parentconfig);
	$self->config()->policy("cache","local");
	$self->config()->basedoc($parentconfig->basedoc());

	# --- download everything first
# FIX-ME --- cacheing is broken
	$self->parse("download");
	
	# --- and parse the setup file
	$self->parse("setup");
}

sub store {
	my $self=shift;
	my $location=shift;

	my $fh=$self->openfile(">".$location);
	print $fh $self->location()."\n";
	$fh->close();
}

sub restore {
	my $self=shift;

	my $fh=$self->openfile("<".$location);
        $self->{location}=<$fh>;
	chomp $self->{location};
        $fh->close();

}

sub name {
	my $self=shift;

	@_?$self->{name}=shift
	  :$self->{name};
}

sub version {
	my $self=shift;

	@_?$self->{version}=shift
	  :$self->{version};
}

sub location {
	my $self=shift;

	@_?$self->{location}=shift
	  :$self->{location};
}

sub meta {
	my $self=shift;

	my $string=$self->name()." ".$self->version()." located at :\n  ".
		$self->location;
}

sub configitem {
	my $self=shift;
	my $location=shift;
	
	$self->config()->find("ConfigItem",@_);
}

sub addconfigitem {
	my $self=shift;
	my $url=shift;

	my $docref=$self->activatedoc($url);
        # Set up the document
        $docref->setup();
	$self->config()->storepolicy("local");
	$docref->save();
}

# -------------- Tags ---------------------------------
# -- init parse
sub Project_Start {
	my $self=shift;
	my $name=shift;
	my $hashref=shift;

	$self->checktag($name,$hashref,'name');
	$self->checktag($name,$hashref,'version');

	$self->name($$hashref{'name'});
	$self->version($$hashref{'version'});
}


sub Project_text {
	my $self=shift;
	my $name=shift;
        my $string=shift;

	print $string;
}

# ---- download parse

sub Use_download_Start {
	my $self=shift;
	my $name=shift;
        my $hashref=shift;

	$self->checktag($name,$hashref,'url');
	print "Downloading .... ".$$hashref{'url'}."\n";
	$self->getfile($$hashref{'url'});
}

# --- setup parse

sub Use_Start {
	my $self=shift;
	my $name=shift;
        my $hashref=shift;
	
	$self->checktag($name,$hashref,'url');
	$self->addconfigitem($$hashref{'url'});
}
