# fluent-plugin-tkgi-metadata-parser

## Description

This Fluentd parser plugin parses metadata received from Tanzu Kubernetes Grid Integrated Edition (TKGI) or Tanzu Kubernetes Grid (TKG).

TKG(I) uses [RFC 5424 - The Syslog Protocol](https://tools.ietf.org/html/rfc5424), this plugin parses specifically the syslog5424_sd field if you use standard parser to parse syslog5424 logs initially, but you can use any field which consists of Kubernetes metadata.

e.g
```log
"syslog5424_sd":"[kubernetes@47450 pod-template-hash=\"6cdc894687\" app.kubernetes.io/component=\"operator\" app.kubernetes.io/instance=\"prometheus\" app.kubernetes.io/managed-by=\"Helm\" app.kubernetes.io/name=\"kube-prometheus\" helm.sh/chart=\"kube-prometheus-3.2.0\" namespace_name=\"prometheus\" object_name=\"prometheus-kube-prometheus-operator-6cdc894687-c56bf\" container_name=\"prometheus-operator\" vm_id=\"04c2872a-768a-4577-944a-87842407f582\"]"
```

## Installation

```shell
$ td-agent-gem install fluent-plugin-tkgi-metadata-parser
```


## Usage

To parse log initially when it comes to Fluentd you need to apply syslog5424 parser, example below uses [grok parser plugin](https://github.com/fluent/fluent-plugin-grok-parser) but feel free to use any other parser of your choice.

```conf
<source>
    @type tcp
    port 6514
    key_name message
    <parse>
        @type grok
        grok_failue_key _grokparsefailure
        <grok>
            pattern %{SYSLOG5424PRI}%{NONNEGINT:syslog5424_ver} +(?:%{TIMESTAMP_ISO8601:syslog5424_ts}|-) +(?:%{HOSTNAME:syslog5424_host}|-) +(?:%{NOTSPACE:syslog5424_app}|-) +(?:%{NOTSPACE:syslog5424_proc}|-) +(?:%{WORD:syslog5424_msgid}|-) +(?:%{SYSLOG5424SD:syslog5424_sd}|-|) +%{GREEDYDATA:syslog5424_msg}
        </grok>
    </parse>
    tag tkgi
</source>
```

### Plugin configuration

```conf
<filter tkgi>
    @type parser
    key_name syslog5424_sd
    reserve_data true
    reserve_time true
    <parse>
      @type tkgi_metadata
      es_mode true
    </parse>
</filter>
```

### Once parsed the output looks like this:

```json
{
  "_index": "k8s-2020.12.31",
  "_type": "_doc",
  "_id": "2zqJunYBHg9f6MMRmev2",
  "_version": 1,
  "_score": null,
  "_source": {
    "syslog5424_pri": "14",
    "syslog5424_ver": "1",
    "syslog5424_ts": "2020-12-31T20:41:24.224539+00:00",
    "syslog5424_host": "XXXX",
    "syslog5424_app": "pod.log/prometheus/prometheus-kube-prometheus-op",
    "syslog5424_proc": "-",
    "syslog5424_msg": "something very important",
    "app_kubernetes_io/component": "operator",
    "app_kubernetes_io/instance": "prometheus",
    "app_kubernetes_io/managed-by": "Helm",
    "app_kubernetes_io/name": "kube-prometheus",
    "helm_sh/chart": "kube-prometheus-3.2.0",
    "pod-template-hash": "6cdc894687",
    "namespace_name": "prometheus",
    "object_name": "prometheus-kube-prometheus-operator-6cdc894687-c56bf",
    "container_name": "prometheus-operator",
    "vm_id": "04c2872a-768a-4577-944a-87842407f582",
    "source": "kubernetes",
    "source_id": "47450",
    "@timestamp": "2020-12-31T14:41:25.003082896-06:00",
    "tag": "tkgi"
  }
  ```

## Optional Parameters

- **delimiter**
    
    delimiter which separate each key-value pairs.
    whitespaces or tabs can be given in quotes: ie, "` `" or "`\t`" .
    By default it is "` `".

- **es_mode**

    When using Elasticsearch as a storage database, it expects mapping to be an object and not text, due to Kubernetes label/annotation naming conventions you might get the following error:

    ```
    <Fluent::Plugin::ElasticsearchErrorHandler::ElasticsearchError: 400 - Rejected by Elasticsearch [error type]: mapper_parsing_exception [reason]: 'Could not dynamically add mapping for field [app.kubernetes.io/component]. Existing mapping for [app] must be of type object but found [text].'> 
    ```

    This issue is caused by label/annotation dots (`.`) creating hierarchy in Elasticsearch documents. If an annotation has a structure like this: `example.annotation.data: some-data` and a different one contains `example.annotation: value` their mapping will conflict, as `example.annotation` is both an object and a keyword.

    To avoid this, when set to `true` this plugin replaces (`.`) with (`_`)

    By default, it is `false`   

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## TODO:
Remove grok parser dependency to parse syslog initially.
