# Copyright 2022 Daniel J. Lemke <dlemke@taklesoftware.com>
# This software is licensed under the MIT License. See LICENSE for details.
use strict;
use warnings;
use autodie;
use Cwd qw(getcwd);
use DateTime;
use Net::SMTP;
use Net::SMTP::Server;
use Net::SMTP::Server::Client;
use Scalar::Util qw(reftype);
use lib ".";
use MyConfig;

sub valid_mail;
sub logger;
sub die_logger;

my $config_dir = getcwd . '/config';
our $config = MyConfig::read_config $config_dir;

my $server = Net::SMTP::Server->new(
	$config->{localhost},
	$config->{localport}
) or die_logger $config->{logfile}, "Unable to create server.";

while(my $conn = $server->accept()) {
	my $address = $conn->peerhost;
	my $client = new Net::SMTP::Server::Client $conn or 
		die_logger $config->{logfile}, "Unable to create client connection: $!\n";
	$client->process or next;

	my $to;
	for (@{$client->{TO}}) {
		$to .= $_ . ';';
	}
	# Use this for grabbing the right data from the hash, but still use
	# $client->{FROM} when actually sending the mail.
	my $from = $client->{FROM};
	$from =~ s/[<>]*//g;

	my ($valid, $from_index) = valid_mail($address, $from, $to);
	unless ($valid) {
		logger $config->{logfile}, "Received invalid mail from $address trying to send from $from to $to.\n";
		next;
	}

	my $mail = Net::SMTP->new(
		"$config->{remotehost}:$config->{remoteport}",
		Timeout => $config->{timeout},
		Debug => $config->{debug},
		Hello => $config->{remotehost},
	) or die_logger $config->{logfile}, "Couldn't connect to remote server $config->{remotehost}.";

	$mail->starttls(
		SSL_verify_mode => $config->{sslverify},
		verify_hostname => $config->{verifyhostname},
		Debug => $config->{debug}) or
		die_logger $config->{logfile}, "Couldn't STARTTLS with remote server $config->{remotehost}";
	if ($config->{authwithdomain}) {
		$mail->auth(
			$from, 
			"$config->{allowed_from}[$from_index]{secret}") or
		die_logger $config->{logfile}, "Couldn't authenticate login for $from on server $config->{remotehost}";
	} else {
		my @user = split /@+/, $from;
		$mail->auth(
			$user[0],
			"$config->{allowed_from}[$from_index]{secret}") or
		die_logger $config->{logfile}, "Couldn't authenticate login for $user[0] from $from on server $config->{remotehost}";
	}
	# $client->{FROM} is used to fit the formatting expected without having to
	# mangle $from.
	$mail->mail($client->{FROM}); 
	$mail->recipient($to); 
	$mail->data();
	$mail->datasend("$client->{MSG}");
	$mail->dataend();
	$mail->quit;
	logger $config->{logfile}, "Mail from $address sent to $to from $from.";
}

sub valid_mail {
	my ($address, $from, @to) = @_;
	my $from_valid = 0;
	my $to_valid = 1;
	my @tos_valid;
	my $address_valid = 0;
	our $config;
	my $from_index;

	for (my $i = 0; $i < $#to; $i++) {
		$tos_valid[$i] = 0;
	}

	for (my $i = 0; $i < @{$config->{allowed_from}}; $i++) {
		$from_valid = 1 if ($from eq $config->{allowed_from}[$i]{email});
		$address_valid = 1 if ($address eq $config->{allowed_from}[$i]{address});
		#print("$config->{allowed_from}[$i]{address}");
		#print("config->{allowed_from}[$i]")
		for (my $j = 0; $j < $#to; $j++) {
			for my $vto (@{$config->{allowed_to}}) {
				if ($to[$j] =~ /$vto/) {
					$tos_valid[$i] = 1;
				}
			}
		}
	}

	return ($from_valid * $to_valid * $address_valid, $from_index);
}

sub write_logger {
	my ($logfile, $message) = @_;

	open my $fh, ">", $logfile;
	print $fh "$message\n";
	close $fh;
}

sub logger {
	my ($logfile, $message) = @_;
	my $date = DateTime->now;

	write_logger $logfile, "$date: $message";
	print "$date: $message\n";
}

sub die_logger {
	my ($logfile, $message) = @_;
	my $date = DateTime->now;

	write_logger $logfile, "$date: DIE - $message";
	die "$date: DIE - $message\n";
}

