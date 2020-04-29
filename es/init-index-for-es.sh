# 1、创建索引
curl -X PUT 'http://host.docker.internal:9200/hot'

# 2、关闭索引
curl -X POST 'http://host.docker.internal:9200/hot/_close'

# 3、初始化所有的：ik_max_word + html_strip + 同义词 + 停止词 （不要修改此处的设置）
curl -XPUT 'http://host.docker.internal:9200/_all/_settings?preserve_existing=true&expand_wildcards=closed' -H 'Content-Type:application/json'  -d '{
  "index.analysis.filter.SYNONYM_FILTER.type" : "synonym",
  "index.analysis.filter.SYNONYM_FILTER.synonyms_path" : "/usr/share/elasticsearch/config/analysis-ik/custom_synonym.dic",
  "index.analysis.filter.STOPWORD_FILTER.type" : "stop",
  "index.analysis.filter.STOPWORD_FILTER.stopwords_path" : "/usr/share/elasticsearch/config/analysis-ik/custom_stopword.dic",
  "index.analysis.analyzer.MAX_SEARCH.filter" : ["SYNONYM_FILTER","STOPWORD_FILTER"],
  "index.analysis.analyzer.MAX_SEARCH.char_filter":["html_strip"],
  "index.analysis.analyzer.MAX_SEARCH.tokenizer" : "ik_max_word",
  "index.analysis.analyzer.MAX_SEARCH.type" : "custom",
  "index.analysis.analyzer.SMART_SEARCH.filter" : ["SYNONYM_FILTER","STOPWORD_FILTER"],
  "index.analysis.analyzer.SMART_SEARCH.char_filter":["html_strip"],
  "index.analysis.analyzer.SMART_SEARCH.tokenizer" : "ik_smart",
  "index.analysis.analyzer.SMART_SEARCH.type" : "custom",
  "index.analysis.analyzer.PINYIN.tokenizer":"PINYIN_TOKEN",
  "index.analysis.analyzer.PINYIN.char_filter":["html_strip"],
  "index.analysis.tokenizer.PINYIN_TOKEN.type":"pinyin"
}'

# 4、为指定的字段添加相应的属性  hours = ceil( time() / 60 / 60 ) 
curl -X PUT 'http://host.docker.internal:9200/hot/_mapping' -H 'Content-Type: application/json' -d '
{
  "properties": {
    "word" : {"type": "text","analyzer":"MAX_SEARCH", "search_analyzer": "MAX_SEARCH", "fields":{
      "pinyin":{"type": "text","store": false,"term_vector": "with_offsets","analyzer": "PINYIN","boost": 10}
    }},
    "count": {"type": "integer"},
    "hours": {"type": "integer"},
    "id":{"type":"keyword","boost": 1000}
  }
}'

# 5、 开启索引
curl -X POST 'http://host.docker.internal:9200/hot/_open'