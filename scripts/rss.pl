#!/usr/bin/perl

use strict;
use CGI qw(:standard);
use LWP::Simple qw/get/;
use JSON::Parse 'parse_json';
use utf8;

my $qtables = new CGI;
print $qtables->header('text/xml');

print qq(<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0">
<channel>
<title>Evènements E-EISTI</title>
<link>http://eeisti.eistiens.net/</link>
<description>Nos évènements à venir!</description>);

	#Recup infos chez FB
	my $accesstoken="non";

	#D'abord, les derniers events pour la page de l'assoc.	
	my $uri = 'https://graph.facebook.com/v2.4/1016975154983075/events?access_token='.$accesstoken;
	my $req = HTTP::Request->new( 'GET', $uri );

	#Execution de la requête construite avec LWP
	my $ua = LWP::UserAgent->new; 
	my $res = $ua->request($req);
	
	#$res est la réponse JSON. On la décode, et on récupère le tableau data, qui contient nos events.
	my $jsonresponse = $res -> decoded_content;
	my $hash = parse_json($jsonresponse);
	
	#eval {
	unless (exists $hash->{"error"})
	{
		my $data = $hash->{"data"};

		#On chope les 3 derniers events.
		my $response = "";
		$response .= &eventToRSS(@$data[2],$accesstoken);
		$response .= &eventToRSS(@$data[1],$accesstoken);
		$response .= &eventToRSS(@$data[0],$accesstoken);

		print $response;
	}	
	else 
	{
	print ""; #if an error occurs return an empty string.
	}

print qq(</channel>
	</rss>);


sub eventToRSS{

	#On récupère les infos de l'event
	my $name = $_[0]->{"name"};
	my $time = substr $_[0]->{"start_time"}, 0, 10;
	my $id = $_[0]->{"id"};
	my $place = $_[0]->{"place"}->{"name"};

	#On fait une seconde requête pour choper l'image de l'event.	
	my $uri = 'https://graph.facebook.com/v2.4/'.$id.'?access_token='.$accesstoken.'&fields=cover';
	my $req = HTTP::Request->new( 'GET', $uri );

	#Execution de la requête construite avec LWP
	my $ua = LWP::UserAgent->new; 
	my $res = $ua->request($req);
	
	#$res est la réponse JSON. On la décode, et on récupère le tableau data, qui contient nos events.
	my $jsonresponse = $res -> decoded_content;
	my $hash = parse_json($jsonresponse);
	my $coverdata = $hash->{"cover"};

	my $imgurl = $coverdata->{"source"};

	#On renvoie l'item RSS avec les données correspondantes
	return qq(

		<item>
			<title>$name</title>
			<link>https://www.facebook.com/events/$id</link>
			<pubDate>$time</pubDate>
			<description><![CDATA[<img src="$imgurl"></img>]]></description>
		</item>

			);

}

	
