#!/usr/bin/perl

use strict;
use CGI qw(:standard);
use LWP::Simple qw/get/;
use JSON::Parse 'parse_json';

my $qtables = new CGI;
print $qtables->header;
print $qtables->start_html(-title => "la data bitch", -encoding => "utf-8")

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
		$response .= &eventToHTML(@$data[2],$accesstoken);
		$response .= &eventToHTML(@$data[1],$accesstoken);
		$response .= &eventToHTML(@$data[0],$accesstoken);

		print $response;
	}	
	else 
	{
	print ""; #if an error occurs return an empty string.
	}


sub eventToHTML{

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

	#On renvoie le bloc d'html avec les données correspondantes
	return qq(

			<div class="col s12 m4">
				 <div class="card medium">
				    <div class="card-image" >
				      <img src="$imgurl">
				    </div>
				    <div class="card-content">
				      <span class="card-title grey-text text-darken-4" style="line-height:35px">$name</span><br/>
				      Le $time à $place<br/>
				      <p><b><a href="https://www.facebook.com/events/$id">Lien vers l'évenement</a></b></p>
				    </div>
				  </div>
				</div>

			);

}

	
