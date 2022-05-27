#!/usr/bin/env perl
# Copyright 2022 Daniel J. Lemke <dlemke@taklesoftware.com>
# This software is licensed under the MIT License. See LICENSE for details.
use strict;
use warnings;
use autodie;
use lib ".";
use GUI;

my $pid = GUI->new(8080)->background();
