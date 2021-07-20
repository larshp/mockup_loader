class lcl_mockup_loader_stub_final definition deferred.
class ltcl_mockup_stub_base_test definition final
  for testing
  duration short
  risk level harmless.

  private section.
    data mo_ml type ref to zcl_mockup_loader.
    data mo_stub_cut type ref to lcl_mockup_loader_stub_final.
    data mt_flights type flighttab.

    methods setup raising zcx_mockup_loader_error.
    methods get_mock_data for testing raising zcx_mockup_loader_error.
    methods control_disable for testing raising zcx_mockup_loader_error.
    methods control_call_count for testing raising zcx_mockup_loader_error.
    methods control_set_proxy for testing raising zcx_mockup_loader_error.
endclass.

class lcl_mockup_loader_stub_final definition final
  inheriting from zcl_mockup_loader_stub_base
  friends ltcl_mockup_stub_base_test.
endclass.
class lcl_mockup_loader_stub_final implementation.
endclass.

class ltcl_mockup_stub_base_test implementation.

  method setup.

    data lt_config type lcl_mockup_loader_stub_final=>tt_mock_config.
    data ls_conf like line of lt_config.

    ls_conf-method_name  = 'METHOD_SIMPLE'.
    ls_conf-mock_name    = 'EXAMPLE/sflight'.
    ls_conf-output_type ?= cl_abap_typedescr=>describe_by_name( 'FLIGHTTAB' ).
    ls_conf-mock_tab_key = 'CONNID'.
    append ls_conf to lt_config.

    ls_conf-method_name  = 'METHOD_SIFTED'.
    ls_conf-sift_param   = 'I_CONNID'.
    append ls_conf to lt_config.

    mo_ml = zcl_mockup_loader=>create(
      i_type = 'MIME'
      i_path = 'ZMOCKUP_LOADER_EXAMPLE'
      i_encoding = zif_mockup_loader_constants=>encoding_utf16 ).

    mo_ml->load_data(
      exporting
        i_obj    = 'EXAMPLE/sflight'
        i_strict = abap_false
      importing
        e_container = mt_flights ).

    create object mo_stub_cut
      exporting
        it_config = lt_config
        io_ml     = mo_ml.

  endmethod.

  method get_mock_data.

    data lt_exp type flighttab.
    data lr_act type ref to data.
    field-symbols <act> type flighttab.

    lt_exp = mt_flights.

    lr_act = mo_stub_cut->get_mock_data( i_method_name = 'METHOD_SIMPLE' i_sift_value = '1000' ).
    assign lr_act->* to <act>.
    cl_abap_unit_assert=>assert_equals( act = <act> exp = lt_exp ).

    lr_act = mo_stub_cut->get_mock_data( i_method_name = 'METHOD_SIFTED' i_sift_value = '1000' ).
    assign lr_act->* to <act>.
    delete lt_exp where connid <> '1000'.
    cl_abap_unit_assert=>assert_equals( act = <act> exp = lt_exp ).

    lr_act = mo_stub_cut->get_mock_data( i_method_name = 'METHOD_MISSING' i_sift_value = '1000' ).
    cl_abap_unit_assert=>assert_initial( lr_act ).


  endmethod.

  method control_disable.

    data li_control type ref to zif_mockup_loader_stub_control.
    data ls_control like line of mo_stub_cut->mt_control.

    cl_abap_unit_assert=>assert_equals( act = lines( mo_stub_cut->mt_control ) exp = 0 ).

    " Disable all
    li_control ?= mo_stub_cut.
    li_control->disable( ).

    cl_abap_unit_assert=>assert_equals( act = lines( mo_stub_cut->mt_control ) exp = 2 ).
    read table mo_stub_cut->mt_control into ls_control with key method_name = 'METHOD_SIMPLE'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_control-is_disabled exp = abap_true ).
    read table mo_stub_cut->mt_control into ls_control with key method_name = 'METHOD_SIFTED'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_control-is_disabled exp = abap_true ).

    " Enable all
    li_control->enable( ).

    cl_abap_unit_assert=>assert_equals( act = lines( mo_stub_cut->mt_control ) exp = 2 ).
    read table mo_stub_cut->mt_control into ls_control with key method_name = 'METHOD_SIMPLE'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_control-is_disabled exp = abap_false ).
    read table mo_stub_cut->mt_control into ls_control with key method_name = 'METHOD_SIFTED'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_control-is_disabled exp = abap_false ).

    " Disable one
    li_control->disable( 'METHOD_SIMPLE' ).

    cl_abap_unit_assert=>assert_equals( act = lines( mo_stub_cut->mt_control ) exp = 2 ).
    read table mo_stub_cut->mt_control into ls_control with key method_name = 'METHOD_SIMPLE'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_control-is_disabled exp = abap_true ).
    read table mo_stub_cut->mt_control into ls_control with key method_name = 'METHOD_SIFTED'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_control-is_disabled exp = abap_false ).

  endmethod.

  method control_call_count.

    data lt_exp type flighttab.
    data lr_act type ref to data.
    field-symbols <act> type flighttab.
    data li_control type ref to zif_mockup_loader_stub_control.

    li_control ?= mo_stub_cut.
    cl_abap_unit_assert=>assert_equals(
      act = li_control->get_call_count( 'METHOD_SIMPLE' )
      exp = 0 ).

    mo_stub_cut->increment_call_count( 'METHOD_SIMPLE' ).
    cl_abap_unit_assert=>assert_equals(
      act = li_control->get_call_count( 'METHOD_SIMPLE' )
      exp = 1 ).

  endmethod.

  method control_set_proxy.

    cl_abap_unit_assert=>assert_initial( mo_stub_cut->mo_proxy_target ).

    mo_stub_cut->zif_mockup_loader_stub_control~set_proxy_target( me ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_stub_cut->mo_proxy_target
      exp = me ).

  endmethod.
endclass.
