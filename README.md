[![CLA assistant](https://cla-assistant.io/readme/badge/watson-developer-cloud/abap-sdk-scp)](https://cla-assistant.io/watson-developer-cloud/abap-sdk-scp)

# ABAP SDK for IBM Watson, using SAP Cloud Platform ABAP Environment

ABAP client library to use the [IBM Watson APIs][wdc]. This is a Community SDK written by ABAPers for the ABAPers in the Open Source community, to provide easy usage of IBM Watson Developer Services in innovation initatives using the SAP Cloud Platform ABAP Environment. It is the choice and responsibility of application developers how this Community SDK is used.

Additionally, as the ABAP SDK is a community release it is not updated with the same schedule as IBM-supported SDKs. Please see more information in [Questions](#questions).

# Choose ABAP SDK release for the applicable ABAP Runtime

| [abap-sdk-nwas](https://github.com/watson-developer-cloud/abap-sdk-nwas) | **abap-sdk-scp** |
|---|---|
| for SAP NetWeaver AS ABAP 7.50+ | for SAP Cloud Platform ABAP Environment 2002+ |
| tested on SAP Business Suite and SAP S/4HANA on-premises edition |  |
|  | `this repository` |

**Note:** The SDK can currently only be deployed in non-Trial instances of the SAP Cloud Platform ABAP Environment. It is planned to make a deployment possible in Trial systems as well later this year.

---

<details>
  <summary>Table of Contents</summary>

  * [Announcements](#announcements)
  * [Before you begin](#before-you-begin)
  * [Installation](#installation)
  * [SSL Certificates](#ssl-certificates)
  * [Credentials](#credentials)
  * [Configuration table](#configuration-table)
  * [IAM Authentication](#iam-authentication)
  * [Usage](#usage)
  * [API Reference](#api-reference)
  * [Questions](#questions)
  * [License](#license)
  * [Contributors](#contributors)
  * [Acknowledgements](#acknowledgements)
</details>

## ANNOUNCEMENTS
### Minor version 0.3.0 released
Version v0.3.0 of the SDK has been released and includes one breaking change - see what's changed in the [migration guide](MIGRATION-V0.3.0.md).

## Before you begin
* You need an [IBM Cloud][ibm_cloud_onboarding] account.

## Installation

The client library is provided as ABAP Git Repository. Proceed as follows to clone the ABAP SDK code to your SAP system.
1. Install the [abapGit Plug-In][abapgit_plugin] for ADT.
2. Use abapGit to clone the ABAP SDK Git repository into your SAP system.
3. Assign the ABAP SDK to the package `ZIBMC` when performing setup of the abapGit repository.

## SSL Certificates
Communication between SAP and the IBM Cloud is secured by the Transport Layer Security (TLS) protocol, also known as Secure Sockets Layer (SSL). SSL requires certificates that must be stored in the SCP Certificate Trust List, which can be maintained through the SCP ABAP environment dashboard. Ensure that the *DigiCert Global Root CA* certificate is installed.

## Credentials

Before you can access a specific service from your SAP system, you must create a service instance in the IBM Cloud and obtain credentials. The credentials can be shared among multiple end users of the SAP system, but you must ensure that the selected plan is sufficient to support the expected number of calls or the expected data volume. Please note that some plans may have restrictions on the allowed methods, so make sure to select the right plan for your purpose.

All currently supported services support IAM authentication (see below). Service credentials consist of an API Key and a URL. Both the API Key and the URL are character values that can be viewed through the IBM Cloud dashboard and need to be provided as parameters `i_apikey` and `i_url` to method `zcl_ibmc_service_ext=>get_instance`.

You can store the values with your application, but it is suggested to do that in an encrypted format. Using cloud services usually creates costs based on usage for the owner of the service instance, and anyone with the credentials can use the service instance at the owner's expenses. If you want to distribute the costs over multiple cost centers, you need to create a service instance and provide service credentials for each cost center separately.


## Configuration table

Service credentials and other parameters that must be specified at Watson service wrapper ABAP class instantiation can also be provided in table `ZIBMC_CONFIG`. This table has three keys:

| Table Key    | Description                                                                                                                            |
|:------------ |:-------------------------------------------------------------------------------------------------------------------------------------- |
| SERVICE      | The ABAP class name without prefix ZCL_IBMC_                                                                                           |
| INSTANCE_UID | ID chosen by application developer that must be provided by application as parameter to method `zcl_ibmc_service_ext=>get_instance()` |
| PARAM        | The parameter name                                                                                                                     |

<details>
  <summary>List of configuration parameters in table ZIBMC_CONFIG</summary>

| Parameter Name    | Default Value     | Description                                                                 |
|:----------------- |:----------------- |:--------------------------------------------------------------------------- |
| URL               | service-dependent | Watson service url                                                          |
| APIKEY            |                   | Watson service API keys                                                     |
| AUTH_NAME         | service-dependent | Authorization, `IAM` or `basicAuth`                                         |

</details>


## IAM Authentication

Identity and Access Management (IAM) is a bearer-token based authentication method. Token management is either performed by the ABAP SDK or must be implemented by the SDK user.<br/>
If a value for apikey is provided by the caller in method `zcl_ibmc_service_ext=>get_instance()`, the ABAP SDK generates a bearer-token under the cover when needed and refreshes it when it is about to expire.<br/>
If apikey is not provided for method `zcl_ibmc_service_ext=>get_instance()`, the ABAP SDK user must implement an individual token management. Before a service method is called the first time, a valid bearer-token must be provided to the Watson service wrapper ABAP class instance as follows:
```abap
  lo_service_class->set_bearer_token( i_bearer_token = '...' ).
```
Afterwards, service methods can be called as long as the provided token is valid. When the token has expired, the method above must be called again with a new (refreshed) bearer-token as parameter.


## Usage

The client library is delivered as package *ZIBMC*. Once the Git Repository has been cloned to the SAP system, a Watson service instance is wrapped by an ABAP class instance.<br>
The following Watson services are currently supported:

| Service                        | ABAP Class Name                |
|:------------------------------ |:------------------------------ |
| Compare and Comply             | ZCL_IBMC_COMPARE_COMPLY_V1     |
| Discovery                      | ZCL_IBMC_DISCOVERY_V1          |
| Language Translator            | ZCL_IBMC_LANG_TRANSLATOR_V3    |
| Natural Language Classifier    | ZCL_IBMC_NAT_LANG_CLASS_V1     |
| Natural Language Understanding | ZCL_IBMC_NAT_LANG_UNDRSTND_V1  |
| Personality Insights           | ZCL_IBMC_PERSONAL_INSIGHTS_V3  |
| Speech to Text                 | ZCL_IBMC_SPEECH_TO_TEXT_V1     |
| Text to Speech                 | ZCL_IBMC_TEXT_TO_SPEECH_V1     |
| Tone Analyzer                  | ZCL_IBMC_TONE_ANALYZER_V3      |
| Visual Recognition             | ZCL_IBMC_VISUAL_RECOGNITION_V3 |
|                                | ZCL_IBMC_VISUAL_RECOGNITION_V4 |
| Watson Assistant               | ZCL_IBMC_ASSISTANT_V1          |
|                                | ZCL_IBMC_ASSISTANT_V2          |

Using the client library requires two steps:

1. Create an instance of the Watson service wrapper ABAP class by calling method `zcl_ibmc_service_ext=>get_instance`.
```abap
  data:
    lo_service_class type <ABAP Class Name>.

  zcl_ibmc_service_ext=>get_instance(
    exporting
      i_url      = <url>
      i_apikey   = <api key>
      ...
    importing   
      eo_instance = lo_service_class ).
```

2. Call the Watson service API endpoint by invoking the corresponding class method.
```abap
  try.
      lo_service_class->method(
        exporting
          is_input = ...
        importing
          es_output = ... ).
    catch zcx_ibmc_service_exception into data(lo_service_exception).
      ...
  endtry.
```

<details>
  <summary>Text to Speech Example</summary>

```abap
* List all voices provided by Watson Text to Speech

  " declare variables
  data:
    lv_apikey            type string value '...',
    lo_text_to_speech    type ref to zcl_ibmc_text_to_speech_v1,
    lo_service_exception type ref to zcx_ibmc_service_exception,
    ls_voice             type zcl_ibmc_text_to_speech=>t_voice,
    lt_voices            type zcl_ibmc_text_to_speech=>t_voices.

  " get Watson Text-to-Speech service instance
  zcl_ibmc_service_ext=>get_instance(
    exporting
      i_url    = 'https://api.kr-seo.text-to-speech.watson.cloud.ibm.com/instances/<uuid>'
      i_apikey = lv_apikey
    importing
      eo_instance = lo_text_to_speech ).

  " call Watson Text-to-Speech service to retrieve available voices
  try.
      lo_text_to_speech->list_voices(
        importing
          e_response = lt_voices ).

    catch zcx_ibmc_service_exception into lo_service_exception.
      message lo_service_exception type 'E'.
  endtry.

  " evaluate voices
  loop at lt_voices-voices into ls_voice.
    ...
  endloop.
```

</details>

<details>
  <summary>Natural Language Understanding Example</summary>

```abap
* Analyze www.ibm.com using Watson Natural Language Understanding

  " declare variables
  data:
    lv_apikey            type string value '...',
    lo_instance          type ref to zcl_ibmc_nat_lang_undrstnd_v1,
    lo_service_exception type ref to zcx_ibmc_service_exception,
    ls_parameter         type zcl_ibmc_nat_lang_undrstnd_v1=>t_parameters,
    ls_analysis_results  type zcl_ibmc_nat_lang_undrstnd_v1=>t_analysis_results.

  " get Watson Natural Language Understanding service instance
  zcl_ibmc_service_ext=>get_instance(
    exporting
      i_url     = 'https://api.eu-de.natural-language-understanding.watson.cloud.ibm.com/instances/<uuid>'
      i_apikey  = lv_apikey
      i_version = '2019-07-12'
    importing
      eo_instance = lo_instance ).

  " set the input parameters
  ls_parameters-url                         = 'www.ibm.com'.
  ls_parameters-return_analyzed_text        = zcl_ibmc_service=>c_boolean_true.
  ls_parameters-features-entities-emotion   = zcl_ibmc_service=>c_boolean_true.
  ls_parameters-features-entities-sentiment = zcl_ibmc_service=>c_boolean_true.
  ls_parameters-features-keywords-emotion   = zcl_ibmc_service=>c_boolean_true.
  ls_parameters-features-keywords-sentiment = zcl_ibmc_service=>c_boolean_true.

  " call Watson Natural Language Understanding service to analyze URL www.ibm.com
  try.
      lo_instance->analyze(
        exporting
	  i_parameters = ls_parameters
        importing
          e_response = ls_analysis_results ).

    catch zcx_ibmc_service_exception into lo_service_exception.
      message lo_service_exception type 'E'.
  endtry.

  " retreive analysis results from ls_analysis_results

```

</details>

<details>
  <summary>Personality Insights Example</summary>

```abap
* Analyze profile using example text using Watson Personality Insights

  " declare variables
  data:
    lv_apikey                  type string value '...',
    lo_personality_insights    type ref to zcl_ibmc_personal_insights_v3,
    lo_service_exception       type ref to zcx_ibmc_service_exception,
    ls_content_item            type zcl_ibmc_personal_insights_v3=>t_content_item,
    ls_response                type zcl_ibmc_personal_insights_v3=>t_profile,
    ls_content                 type zcl_ibmc_personal_insights_v3=>t_content,
    lv_content_language        type string value 'en',
    lv_accept_language         type string value 'en',
    lv_raw_scores              type boolean value 'C_BOOLEAN_FALSE',
    lv_csv_headers             type boolean valiue 'C_BOOLEAN_FALSE',
    lv_consumption_preferences type boolean value 'C_BOOLEAN_FALSE',
    lv_accept                  type string value 'text/csv'.

  " get Watson Personality Insights service instance
  zcl_ibmc_service_ext=>get_instance(
    exporting
      i_url     = 'https://api.eu-gb.personality-insights.watson.cloud.ibm.com/instances/<uuid>'
      i_apikey  = lv_apikey
      i_version = '2018-05-01'
    importing
      eo_instance = lo_personality_insights ).

  " store text to be analyzed into ls_content
  " concatenate ... into ls_content_item-content
  " append ls_content_item to ls_content-contentitems

  " call Watson Personality Insights service to analyze text in ls_content
  try.
      lo_personality_insights->profile(
        exporting
          i_content                 = ls_content
          i_content_language        = lv_content_language
          i_accept_language         = lv_accept_language
          i_raw_scores              = lv_raw_scores
          i_csv_headers             = lv_csv_headers
          i_consumption_preferences = lv_consumption_preferences
        importing
          e_response = ls_response ).

    catch zcx_ibmc_service_exception into lo_service_exception.
      message lo_service_exception type 'E'.
  endtry.

  " retreive profile analysis results from ls_response

```

</details>

<details>
  <summary>Language Translator Example</summary>

```abap
* Translate text from English to German using Watson Language Translator

  " declare variables
  data:
    lv_apikey            type string value '...',
    lo_lang_translator   type ref to zcl_ibmc_lang_translator_v3,
    lo_service_exception type ref to zcx_ibmc_service_exception,
    ls_request           type zcl_ibmc_lang_translator_v3=>t_translate_request,
    lv_text              type string,
    ls_trans             type zcl_ibmc_lang_translator_v3=>t_translation_result.    

  " get Watson Language Translator service instance
  zcl_ibmc_service_ext=>get_instance(
    exporting
      i_url      = 'https://api.us-south.language-translator.watson.cloud.ibm.com/instances/<uuid>'
      i_apikey   = lv_apikey
      i_version  = '2018-05-01'
    importing
      eo_instance = lo_lang_translator ).

  " store text to be translated into ls_request and set the languages
  lv_text = 'Welcome'.
  append lv_text to ls_request-text.
  ls_request-model_id = 'en-de'.
  ls_request-source = 'EN'.
  ls_request-target = 'DE'.  

  " call Watson Language Translator service to translate the text in ls_request
  try.
      lo_lang_translator->translate(
        exporting
          i_request     =   ls_request
          i_contenttype = 'application/json'
          i_accept      = 'application/json'
        importing
          e_response = ls_trans ).

    catch zcx_ibmc_service_exception into lo_service_exception.
      message lo_service_exception type 'E'.
  endtry.

  " retreive translation results from ls_trans

```

</details>

## API Reference

GitHub Pages contain the [ABAP Client Library for Watson API Reference](https://watson-developer-cloud.github.io/abap-sdk-nwas/).

## Questions

The ABAP SDK is a Community SDK for IBM Watson, created by the IBM Watson development community and SAP's ABAP development community - written by ABAPers from IBM Cloud, IBM Services and IBM Systems. Therefore as a community release it is not updated with the same schedule as IBM-supported SDKs, and does not include support by IBM. For more information on IBM-supported SDKs and the update policy, please see https://cloud.ibm.com/docs/watson?topic=watson-using-sdks

If you have questions about the IBM Watson services or are having difficulties using the APIs, please ask a question at [dW Answers](https://developer.ibm.com/answers/questions/ask/?topics=watson) or [Stack Overflow](http://stackoverflow.com/questions/ask?tags=ibm-watson-cognitive).

## License

This library is licensed under the [Apache 2.0 license][license].

---

## Contributors

* Christian Bartels
* Joachim Rese
* Jochen Röhrig
* Aleksandar Debelic

## Acknowledgements

* Bradley Knapp (Sponsor)
* Devraj Bardhan (Sponsor)
* Sean Freeman (Sponsor)

In addition, we would like to thank the [abapGit][abapgit] contributors and the SAP Mentors of this team.

[wdc]: https://cloud.ibm.com/docs?tab=api-docs&category=ai
[ibm_cloud]: https://cloud.ibm.com/
[ibm_cloud_onboarding]: https://cloud.ibm.com/registration?target=/developer/watson&cm_sp=WatsonPlatform-WatsonServices-_-OnPageNavLink-IBMWatson_SDKs-_-ABAP
[license]: http://www.apache.org/licenses/LICENSE-2.0
[abapgit_plugin]: https://eclipse.abapgit.org/updatesite/
[abapgit_docs]: https://docs.abapgit.org/
[abapgit]: https://github.com/larshp/abapGit
