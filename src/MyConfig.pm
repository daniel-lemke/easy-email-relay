# Copyright 2022 Daniel J. Lemke <dlemke@taklesoftware.com>
# This software is licensed under the MIT License. See LICENSE for details.
package MyConfig;
use strict;
use warnings;
use autodie;

sub read_config {
	my $dir = shift;
	opendir my $dh, $dir or die "Can't open configuration directory.";
	my %config;
	#%config{allowed_from} = ();

	for my $file (readdir $dh) {
		if ($file =~ /^config.txt|allowed_to.txt|allowed_from.txt$/) {
			open my $fh, "<", "$dir/$file" or
				die "Can't open config file $file for reading.\n";

			if ($file =~ /^config.txt$/) {
				while (<$fh>) {
					my @words = split /\s+/, $_;
					$config{$words[0]} = $words[1];
				}
			} elsif ($file =~ /^allowed_to.txt$/) {
				while (<$fh>) {
					my @words = split /\s+/, $_;
					push @{$config{allowed_to}}, $words[0];
				}
			} elsif ($file =~ /^allowed_from.txt$/) {
				while (<$fh>) {
					my @words = split /\s+/, $_;
					push @{$config{allowed_from}}, {
						email => $words[0],
						secret => $words[1],
						address => $words[2]
					};
					#push $config{allowed_from}, {$words[0]}{secret} = $words[1];
					#$config{allowed_from}{$words[0]}{address} = $words[2];
				}
			}
			close $fh;
		}
	}

	return \%config;
}

sub write_config {
	my ($dir, $config) = @_;
	open my $fh, ">", "$dir/config.txt";
	for my $k (sort keys %{$config}) {
		next if $k =~ /^allowed_from|allowed_to$/;
		print $fh "$k\t$config->{$k}\n";
	}
	close $fh;
	open $fh, ">", "$dir/allowed_to.txt";
	for my $v (@{$config->{allowed_to}}) {
		print $fh "$v\n";
	}
	close $fh;
	open $fh, ">", "$dir/allowed_from.txt";
	for my $k (sort keys %{$config->{allowed_from}}) {
		print $fh "$k\t$config->{allowed_from}{$k}{secret}\t$config->{allowed_from}{$k}{address}\n";
	}
	close $fh;
}

sub create_default_files {
	my $dir = shift;
	my %config = (
		localhost => '127.0.0.1',
		localport => '2525',
		remotehost => 'smtp.mymailserver.com',
		remoteport => '587',
		allowed_to => [
			'myaddress@mymailserver.com',
			'someotheraddress@mymailserver.com'
		],
		allowed_from => {
			'mysender@mymailserver.com' => {
				secret => 'mysecret',
				address => '127.0.0.1/8'
			},
			'myothersender@mymailserver.com' => {
				secret => 'mysecret',
				address => '192.168.1.1'
			}
		}
	);

	save_config $dir, \%config;
}
1;
