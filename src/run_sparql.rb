# coding: utf-8

# usgage:
#
#  $ruby run_sparql.rb [sparql] | jq '.' | lv
#

require 'uri'
require 'net/http/persistent'

builtin =<<EOQ
PREFIX dbpp: <http://dbpedia.org/property/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX yago: <http://dbpedia.org/class/yago/>
PREFIX dbpr: <http://dbpedia.org/resource/>
PREFIX dbpo: <http://dbpedia.org/ontology/>

SELECT ?cname
WHERE {
  ?city a dbpo:City .
  ?city rdfs:label ?cname .

  FILTER( lang(?cname) = "ja" )
 }
# ORDER BY DESC(?population)
LIMIT 1000
EOQ

sparql = ARGV[0] || builtin
http = Net::HTTP::Persistent.new

uri = URI "http://dbpedia.org/sparql"
params = {
  'default-uri_graph' => 'http://dbpedia.org',
  'query' => sparql,
  'format' => 'application/json',
}

uri.query = URI.encode_www_form( params )
response = http.request uri

if response.is_a? Net::HTTPOK
  puts response.body.strip!
else
  p response
  raise "HTTP ERROR"
end
