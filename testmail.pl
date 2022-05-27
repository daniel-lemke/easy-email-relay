#!/usr/bin/env perl
# Copyright 2022 Daniel J. Lemke <dlemke@taklesoftware.com>
# This software is licensed under the MIT License. See LICENSE for details.
use strict;
use warnings;
use autodie;
use Net::SMTP;

my $mymail = Net::SMTP->new('127.0.0.1:2525',
	Hello=>'mail.netsusa.net',
	Timeout => 30,
	Debug => 1) or die("Couldn't connect to the SMTP server.");

$mymail->mail('monitoring@netsusa.net') or die("Couldn't send mail command."); 
$mymail->recipient('dlemke@netsusa.net') or 
	die("Couldn't send recipient command."); 
$mymail->data() or die("Couldn't initiate data.");
$mymail->datasend("From: monitoring\@netsusa.net\n");
$mymail->datasend("To: dlemke\@netsusa.net\n");
$mymail->datasend("Subject: testing perl\n");
$mymail->datasend("\n");
$mymail->datasend('testing') or die("Couldn't send data testing.");
$mymail->dataend() or die("Couldn't send data end command.");
$mymail->quit or die("Couldn't send quit command.");
