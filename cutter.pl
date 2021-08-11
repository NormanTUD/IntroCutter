#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use autodie;
use Time::Seconds;

use Digest::MD5::File qw(dir_md5_hex file_md5_hex url_md5_hex);

my %options = (
	debug => 0,
	dir => undef,
	tmp => "./tmp"
);

sub debug (@) {
	if($options{debug}) {
		foreach (@_) {
			warn "$_\n";
		}
	}
}

sub main {
	debug "main";

	mkdir $options{tmp} unless -d $options{tmp};

	my %hash_to_file = ();

	while (my $filepath = <$options{dir}/*.mp4>) {
		my $file = $filepath;
		$file =~ s#.*/##g;
		
		my $md5 = file_md5_hex($filepath);

		$hash_to_file{$md5} = $filepath;

		my $this_tmp_dir = "$options{tmp}/$md5";

		if(!-d $this_tmp_dir) {
			debug "$this_tmp_dir does not exist. Creating it";
			mkdir $this_tmp_dir;

			system(qq#ffmpeg -i "$filepath" -r 2 -to 00:02:00 "$this_tmp_dir/output_%04d.png"#);
		}

	}

	my %file_to_timestamp = get_most_likely_intro_end(%hash_to_file);

	open my $fh, '>>', "$options{dir}/.intro_endtime";
	foreach my $filename (keys %file_to_timestamp) {
		my $file = $filename;
		$file =~ s#.*/##g;
		print $fh "$file ::: $file_to_timestamp{$filename}\n";
	}
	close $fh;
}

sub get_most_likely_intro_end {
	my %hash_to_file = @_;
	my $command = "python3 image_analyzer.py $options{tmp}";
	my @hash_to_last_frame_of_intro = map { chomp; $_ } qx($command);

	my %file_to_timestamp = ();

	foreach my $line (@hash_to_last_frame_of_intro) {
		if($line =~ m#(.*) ::: (.*)#) {
			my ($hash, $frame) = ($1, $2);

			my $t = int($frame / 2);
			$file_to_timestamp{$hash_to_file{$hash}} = $t;
		} else {
			die "Invalid Line $line";
		}
	}

	return %file_to_timestamp;
}

sub analyze_args {
	foreach (@_) {
		if(/^--debug$/) {
			$options{debug} = 1;
		} elsif (/^--dir=(.*)$/) {
			my $dir = $1;
			if(-d $dir) {
				$options{dir} = $dir;
			} else {
				die "$dir does not exist";
			}
		} else {
			die "Unknown parameter $_";
		}
	}
}

analyze_args(@ARGV);

main();
