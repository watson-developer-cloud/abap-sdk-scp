* Copyright 2019,2020 IBM Corp. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
CLASS zcl_ibmc_service_arch DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_ibmc_service_arch .

    TYPES to_http_client TYPE REF TO if_web_http_client .
    TYPES to_rest_request TYPE REF TO if_web_http_request .
    TYPES to_rest_response TYPE REF TO if_web_http_response .
    TYPES to_form_part TYPE REF TO if_web_http_request .
    TYPES:
      BEGIN OF ts_client,
        http    TYPE to_http_client,
        request TYPE to_rest_request,
      END OF ts_client .
    TYPES:
      BEGIN OF ts_http_stat,
        code   TYPE i,
        reason TYPE string,
      END OF ts_http_stat .
    TYPES:
      BEGIN OF ts_http_status,
        code   TYPE n LENGTH 3,
        reason TYPE string,
        json   TYPE string,
      END OF ts_http_status .
    TYPES ts_header TYPE zif_ibmc_service_arch~ts_header .
    TYPES tt_header TYPE zif_ibmc_service_arch~tt_header .
    TYPES ts_url TYPE zif_ibmc_service_arch~ts_url .
    TYPES ts_access_token TYPE zif_ibmc_service_arch~ts_access_token .
    TYPES ts_request_prop TYPE zif_ibmc_service_arch~ts_request_prop .

    "! <p class="shorttext synchronized" lang="en">Returns the user's time zone.</p>
    "!
    "! @parameter E_TIMEZONE | user's time zone
    "!
    CLASS-METHODS get_timezone
      RETURNING
        VALUE(e_timezone) TYPE zif_ibmc_service_arch~ty_timezone .
    "! <p class="shorttext synchronized" lang="en">Returns an ABAP module identifier.</p>
    "!
    "! @parameter E_PROGNAME | ABAP module identifier
    "!
    CLASS-METHODS get_progname
      RETURNING
        VALUE(e_progname) TYPE string .
    "! <p class="shorttext synchronized" lang="en">Decodes base64 encoded data to binary.</p>
    "!
    "! @parameter I_BASE64 | Base64-encoded binary
    "! @parameter E_BINARY | Binary data
    "! @raising ZCX_IBMC_SERVICE_EXCEPTION | Exception being raised in case of an error.
    "!
    CLASS-METHODS base64_decode
      IMPORTING
        !i_base64       TYPE string
      RETURNING
        VALUE(e_binary) TYPE xstring
      RAISING
        zcx_ibmc_service_exception .
    "! <p class="shorttext synchronized" lang="en">Returns a HTTP/REST client based on an URL.</p>
    "!
    "! @parameter I_URL | URL
    "! @parameter I_REQUEST_PROP | Request parameters
    "! @parameter E_CLIENT | HTTP/REST client
    "! @raising ZCX_IBMC_SERVICE_EXCEPTION | Exception being raised in case of an error.
    "!
    CLASS-METHODS create_client_by_url
      IMPORTING
        !i_url          TYPE string
        !i_request_prop TYPE ts_request_prop
      EXPORTING
        !e_client       TYPE ts_client
      RAISING
        zcx_ibmc_service_exception .
    "! <p class="shorttext synchronized" lang="en">Returns the default proxy host and port.</p>
    "!
    "! @parameter I_URL | target URL
    "! @parameter E_PROXY_HOST | Proxy host
    "! @parameter E_PROXY_PORT | Proxy port
    "!
    CLASS-METHODS get_default_proxy
      IMPORTING
        !i_url        TYPE ts_url OPTIONAL
      EXPORTING
        !e_proxy_host TYPE string
        !e_proxy_port TYPE string .
    "! <p class="shorttext synchronized" lang="en">Sets request header for basic authentication.</p>
    "!
    "! @parameter I_CLIENT | HTTP/REST client
    "! @parameter I_USERNAME | User name
    "! @parameter I_PASSWORD | Password
    "!
    CLASS-METHODS set_authentication_basic
      IMPORTING
        !i_client   TYPE ts_client
        !i_username TYPE string
        !i_password TYPE string .
    "! <p class="shorttext synchronized" lang="en">Sets a HTTP header.</p>
    "!
    "! @parameter I_CLIENT | HTTP/REST client
    "! @parameter I_NAME | Header field name
    "! @parameter I_VALUE | Header field value
    "!
    CLASS-METHODS set_request_header
      IMPORTING
        !i_client TYPE ts_client
        !i_name   TYPE string
        !i_value  TYPE string .
    "! <p class="shorttext synchronized" lang="en">Sets the URI for a HTTP request.</p>
    "!
    "! @parameter I_CLIENT | HTTP/REST client
    "! @parameter I_URI | URI
    "!
    CLASS-METHODS set_request_uri
      IMPORTING
        !i_client TYPE ts_client
        !i_uri    TYPE string .
    "! <p class="shorttext synchronized" lang="en">Generates a multi-part request body.</p>
    "!
    "! @parameter I_CLIENT | HTTP/REST client
    "! @parameter IT_FORM_PART | Table of form parts
    "! @raising ZCX_IBMC_SERVICE_EXCEPTION | Exception being raised in case of an error.
    "!
    METHODS add_form_part
      IMPORTING
        !i_client     TYPE ts_client
        !it_form_part TYPE zif_ibmc_service_arch~tt_form_part
      RAISING
        zcx_ibmc_service_exception .
    "! <p class="shorttext synchronized" lang="en">Executes a HTTP request.</p>
    "!
    "! @parameter I_CLIENT | HTTP/REST client
    "! @parameter I_METHOD | HTTP method (GET,POST,PUT,DELETE)
    "! @parameter E_RESPONSE | Response of the request
    "! @raising ZCX_IBMC_SERVICE_EXCEPTION | Exception being raised in case of an error.
    "!
    CLASS-METHODS execute
      IMPORTING
        !i_client         TYPE ts_client
        !i_method         TYPE zif_ibmc_service_arch~char
      RETURNING
        VALUE(e_response) TYPE to_rest_response
      RAISING
        zcx_ibmc_service_exception .
    "! <p class="shorttext synchronized" lang="en">Reads character data from a HTTP response.</p>
    "!
    "! @parameter I_RESPONSE | HTTP response
    "! @parameter E_DATA | Character data
    "!
    CLASS-METHODS get_response_string
      IMPORTING
        !i_response   TYPE REF TO if_web_http_response
      RETURNING
        VALUE(e_data) TYPE string .
    "! <p class="shorttext synchronized" lang="en">Set character data for the body of a HTTP request.</p>
    "!
    "! @parameter I_CLIENT | HTTP/REST client
    "! @parameter I_DATA | Character data
    "!
    CLASS-METHODS set_request_body_cdata
      IMPORTING
        !i_client TYPE ts_client
        !i_data   TYPE string .
    "! <p class="shorttext synchronized" lang="en">Set binary data for the body of a HTTP request.</p>
    "!
    "! @parameter I_CLIENT | HTTP/REST client
    "! @parameter I_DATA | Binary data
    "!
    CLASS-METHODS set_request_body_xdata
      IMPORTING
        !i_client TYPE ts_client
        !i_data   TYPE xstring .
    "! <p class="shorttext synchronized" lang="en">Reads binary data from a HTTP response.</p>
    "!
    "! @parameter I_RESPONSE | HTTP response
    "! @parameter E_DATA | Binary data
    "!
    CLASS-METHODS get_response_binary
      IMPORTING
        !i_response   TYPE REF TO if_web_http_response
      RETURNING
        VALUE(e_data) TYPE xstring .
    "! <p class="shorttext synchronized" lang="en">Returns a HTTP response header.</p>
    "!
    "! @parameter I_RESPONSE | HTTP/REST response
    "! @parameter I_HEADER_FIELD | Header field name
    "! @parameter E_VALUE | Header field value
    "!
    CLASS-METHODS get_response_header
      IMPORTING
        !i_response type to_rest_response
        !i_header_field type string
      RETURNING
        VALUE(e_value) type string .
    "! <p class="shorttext synchronized" lang="en">Returns the status of a REST response.</p>
    "!
    "! @parameter I_REST_RESPONSE | HTTP/REST response
    "! @parameter E_STATUS | HTTP status
    "!
    CLASS-METHODS get_http_status
      IMPORTING
        !i_rest_response TYPE REF TO if_web_http_response
      RETURNING
        VALUE(e_status)  TYPE ts_http_status .
    "! <p class="shorttext synchronized" lang="en">Converts STRING data to UTF8 encoded XSTRING.</p>
    "!
    "! @parameter I_STRING | STRING data
    "! @parameter E_UTF8 | UTF8-encoded data
    "!
    CLASS-METHODS convert_string_to_utf8
      IMPORTING
        !i_string     TYPE string
      RETURNING
        VALUE(e_utf8) TYPE xstring
      RAISING
        zcx_ibmc_service_exception .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ibmc_service_arch IMPLEMENTATION.


  METHOD base64_decode.

    e_binary = cl_web_http_utility=>decode_x_base64( i_base64 ).

*    if sy-subrc <> 0.
*      zcl_ibmc_service=>raise_exception( i_msgno = '030' ).  " Decoding of base64 string failed
*    endif.

  ENDMETHOD.


  METHOD convert_string_to_utf8.

    CALL METHOD cl_web_http_utility=>encode_utf8
      EXPORTING
        unencoded = i_string
      RECEIVING
        encoded   = e_utf8
      EXCEPTIONS
        OTHERS    = 1.
    IF sy-subrc <> 0.
      zcl_ibmc_service=>raise_exception( i_text = 'Cannot convert string to UTF-8' )  ##NO_TEXT.
    ENDIF.

  ENDMETHOD.


  METHOD create_client_by_url.

    DATA:
      lv_text TYPE string.

    TRY.
        "create http destination by url
        DATA(lo_http_destination) =
         cl_http_destination_provider=>create_by_url( i_url ).
      CATCH cx_http_dest_provider_error.
    ENDTRY.

    "create HTTP client by destination
    TRY.
        e_client-http = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .
      CATCH cx_web_http_client_error.
        lv_text = `HTTP client cannot be created: ` && lv_text  ##NO_TEXT.
        zcl_ibmc_service=>raise_exception( i_text = lv_text ).
    ENDTRY.

    e_client-request = e_client-http->get_http_request( ).

  ENDMETHOD.


  METHOD execute.

    DATA:
      lo_request   TYPE REF TO if_web_http_request,
      lv_method    TYPE string,
      lv_text      TYPE string,
      lo_exception TYPE REF TO cx_web_http_client_error.

    TRY.
        CASE i_method.
          WHEN zif_ibmc_service_arch~c_method_get.
            lv_method = 'GET'.
            e_response = i_client-http->execute( if_web_http_client=>get ).
          WHEN zif_ibmc_service_arch~c_method_post.
            lv_method = 'POST'.
            e_response = i_client-http->execute( if_web_http_client=>post ).
          WHEN zif_ibmc_service_arch~c_method_put.
            lv_method = 'PUT'.
            e_response = i_client-http->execute( if_web_http_client=>put ).
          WHEN zif_ibmc_service_arch~c_method_delete.
            lv_method = 'DELETE'.
            e_response = i_client-http->execute( if_web_http_client=>delete ).
        ENDCASE.

      CATCH cx_web_http_client_error INTO lo_exception.
        lv_text = lo_exception->get_text( ).
        lv_text = `HTTP ` && lv_method && ` request failed: ` && lv_text  ##NO_TEXT.
        zcl_ibmc_service=>raise_exception( i_text = lv_text i_previous = lo_exception ).
    ENDTRY.


  ENDMETHOD.


  METHOD add_form_part.

    DATA:
      ls_form_part TYPE zif_ibmc_service_arch~ts_form_part,
      lo_part TYPE REF TO if_web_http_request.

    LOOP AT it_form_part INTO ls_form_part.

      lo_part = i_client-request->add_multipart( ).

      IF NOT ls_form_part-content_type IS INITIAL.
        lo_part->set_header_field( i_name = `Content-Type` i_value = ls_form_part-content_type )  ##NO_TEXT.
      ENDIF.

      IF NOT ls_form_part-content_disposition IS INITIAL.
        lo_part->set_header_field( i_name = `Content-Disposition` i_value = ls_form_part-content_disposition )  ##NO_TEXT.
      ELSE.
        lo_part->set_header_field( i_name = `Content-Disposition` i_value = `form-data; name="unnamed"` )  ##NO_TEXT.
      ENDIF.

      IF NOT ls_form_part-xdata IS INITIAL.
        data(lv_length) = xstrlen( ls_form_part-xdata ).
        lo_part->set_binary( i_data = ls_form_part-xdata i_offset = 0 i_length = lv_length ).
      ENDIF.

      IF NOT ls_form_part-cdata IS INITIAL.
        lo_part->set_text( i_text = ls_form_part-cdata ).
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_default_proxy.

  ENDMETHOD.


  METHOD get_http_status.
    DATA: ls_status TYPE ts_http_stat.

    ls_status = i_rest_response->get_status( ).
    e_status-code   = ls_status-code.
    e_status-reason = ls_status-reason.
    TRY.
        e_status-json   = i_rest_response->get_text( ).
      CATCH cx_web_message_error.
        " response may be binary -> ignore
        e_status-json = ''.
    ENDTRY.
  ENDMETHOD.


  METHOD get_progname.

*    e_progname = sy-cprog.

  ENDMETHOD.


  METHOD get_response_binary.

    e_data = i_response->get_binary( ).

  ENDMETHOD.


  METHOD get_response_header.

    e_value = i_response->get_header_field( i_name = i_header_field ).

  ENDMETHOD.


  METHOD get_response_string.

    e_data = i_response->get_text( ).

  ENDMETHOD.


  METHOD get_timezone.

*    e_timezone = sy-zonlo.

  ENDMETHOD.


  METHOD set_authentication_basic.

    i_client-request->set_authorization_basic(
      EXPORTING
        i_username  = i_username
        i_password  = i_password
    ).

  ENDMETHOD.


  METHOD set_request_body_cdata.

    i_client-request->set_text( i_text = i_data ).

  ENDMETHOD.


  METHOD set_request_body_xdata.

    i_client-request->set_binary( i_data = i_data ).

  ENDMETHOD.


  METHOD set_request_header.

    i_client-request->set_header_field( i_name = i_name i_value = i_value ) .

  ENDMETHOD.


  METHOD set_request_uri.

    DATA:
      lo_request TYPE REF TO if_web_http_request.

    i_client-request->set_uri_path( i_uri_path = i_uri ).

  ENDMETHOD.
ENDCLASS.

