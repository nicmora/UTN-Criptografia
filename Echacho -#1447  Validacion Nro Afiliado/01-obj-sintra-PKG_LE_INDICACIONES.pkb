CREATE OR REPLACE PACKAGE BODY SINTRA.PKG_LE_INDICACIONES
AS

/*COMIENZO DE P_RECUPERAR******************************************************/
PROCEDURE P_RECUPERAR ( p_id_indicacion in NUMBER, 
                        p_array_out out tabla_array_out,
                        p_resultado out varchar2 )
AS

/*DEFINICION DE ERRORES********************************************************/
    ok1                 exception;
    error1              exception;
    error2              exception;
    error_select        exception;

    
    
    rec_vistaIndicacion     v_m6_indicacion_tx_cph%rowtype; 
            
    v_paciente                  varchar2(200);
    v_fecha_nac_paciente        date;
    v_edad_paciente             varchar2(30);
    v_provincia                 varchar2(30); 
    v_situacion_indicacion      varchar2(50); 
    v_situacion_registro        varchar2(50); 
    v_tipo_trasplante           varchar2(100);
    v_nro_afiliado              varchar2(20); 
    v_etx                       varchar2(300);
    v_id_etx                    varchar2(30);
    v_tipo_tx_dsc               varchar2(100);
    v_id_establecimiento        varchar2(30);
    v_provincia_establecimiento varchar2(100);
    v_id_tipo_tx                varchar2(30);
    v_error_select              varchar2(200);
    v_comentarios               varchar2(200);    
    
BEGIN
    
    /*  VALIDACIONES*/
    if p_id_indicacion is null then raise error1; end if;  
    
    begin
        select * into rec_vistaIndicacion from v_m6_indicacion_tx_cph where id_indicacion = p_id_indicacion;
        exception when no_data_found then raise error2; 
    end;
       
    p_array_out := tabla_array_out();
    
    /************    datos generales    *******/
    
    v_paciente                  := rec_vistaIndicacion.PACIENTE;
    v_provincia                 := rec_vistaIndicacion.PROVINCIA;
    v_situacion_indicacion      := rec_vistaIndicacion.SITUACION_INDICACION;
    v_situacion_registro        := rec_vistaIndicacion.SITUACION_REGISTRO; 
    
    /*  Inicio Modif Chacho Ticket #1447 27/10/15
    1. Se quita el procentaje financiador 
    2. Se agrega el nro de afiliado
    3. Se agrega comentarios
    
    -- 1. Se quita el procentaje financiador
     IF rec_vistaIndicacion.PORCENTAJE_COBERTURA is null THEN
      v_porcentaje_financiacion   := 0; 
        ELSE
          v_porcentaje_financiacion   := rec_vistaIndicacion.PORCENTAJE_COBERTURA;
    END IF;*/
    
    -- 2. Se agrega el nro de afiliado
    select pf.nro_afiliado
    into v_nro_afiliado
    from M6_PACIENTE_FINANCIADOR pf
    where pf.id_indicacion = rec_vistaIndicacion.id_indicacion;
    
    -- 3. Se agrega comentarios
    select ind.comentario
    into v_comentarios
    from M6_INDICACION ind
    where ind.id_indicacion = rec_vistaIndicacion.id_indicacion;
    
    -- Fin Modif Chacho Ticket #1447 27/10/15
    
    begin
            select descripcion  
            into v_tipo_trasplante 
            from sintra.m6_tipo_trasplante
            where id_tipo_trasplante = rec_vistaIndicacion.id_tipo_trasplante ;
        exception
            when others then 
                v_error_select := 'TIPO DE TRASPLANTE';
                raise error_select;
    end;
    /*** DATOS PARA EL BUSCADOR ***/
    v_id_etx      :=    rec_vistaIndicacion.ID_ETX; 
    v_etx         :=    rec_vistaIndicacion.ETX;       
    
    /*** Parametros para llamar a los buscadores ***/
    --calculamos la edad
    begin
            select fecha_nacimiento
            into v_fecha_nac_paciente
            from persona
            where id_persona = rec_vistaIndicacion.ID_PERSONA;
            v_edad_paciente :=  FLOOR (MONTHS_BETWEEN (SYSDATE, v_fecha_nac_paciente) / 12);
        exception
            when others then 
                v_error_select := 'FECHA DE NACIMIENTO';
                raise error_select;
    end;
    
    --preparamos el id_tipo_tx
    if rec_vistaIndicacion.id_tipo_trasplante in (1,2) then v_id_tipo_tx := 10; end if;
    if rec_vistaIndicacion.id_tipo_trasplante = 3 then v_id_tipo_tx := 9; end if;
        
    begin
            select EST.id_establecimiento, PROV.descripcion, TTX.DESCRIPCION
            into v_id_establecimiento, v_provincia_establecimiento, v_tipo_tx_dsc 
            from m2_etx ETX
            join establecimiento EST on EST.id_establecimiento = ETX.id_establecimiento
            join provincia PROV on PROV.id_provincia = EST.id_provincia 
            join tipo_tx TTX on TTX.ID_TIPO_TX = ETX.id_tipo_tx 
            where id_etx = rec_vistaIndicacion.ID_ETX; 
        exception
            when others then 
                null;
    end;
    /*********/
        
    /* ARRAY PARA LA APLICACION*/
    lib1.array_out_add(p_array_out,0001,'r', v_paciente,null); --NO EXISTE EN APP_COLUMNA, ES JOIN
    lib1.array_out_add(p_array_out,41,'r', v_provincia,null); --provincia del paciente
    lib1.array_out_add(p_array_out,0002,'r', v_situacion_indicacion, null); --NO EXISTE EN APP_COLUMNA
    lib1.array_out_add(p_array_out,0003,'r', v_situacion_registro,null); --NO EXISTE EN APP_COLUMNA
    lib1.array_out_add(p_array_out,0004,'r', rec_vistaIndicacion.id_tipo_trasplante, v_tipo_trasplante); --NO EXISTE EN APP_COLUMNA
    
    /* Inico Modif Chacho Ticket #1448  27/10/15
   Todos pueden ingresar al formulario, pero dependiendo la situacion de la solicitud podrán modificar o no */
    if (rec_vistaIndicacion.id_situacion_indicacion = 1 or rec_vistaIndicacion.id_situacion_indicacion = 4) then
        lib1.array_out_add(p_array_out,0005,'w', v_nro_afiliado, null);
        lib1.array_out_add(p_array_out,0011,'w', v_id_etx, v_etx);
        lib1.array_out_add(p_array_out,0015,'w', v_comentarios, null); --NO EXISTE EN APP_COLUMNA
    elsif v_nro_afiliado is null then
        lib1.array_out_add(p_array_out,0005,'w', v_nro_afiliado, null);
        lib1.array_out_add(p_array_out,0011,'r', v_id_etx, v_etx);
        lib1.array_out_add(p_array_out,0015,'w', v_comentarios, null); --NO EXISTE EN APP_COLUMNA
    else
        lib1.array_out_add(p_array_out,0005,'r', v_nro_afiliado, null);
        lib1.array_out_add(p_array_out,0011,'r', v_id_etx, v_etx);
        lib1.array_out_add(p_array_out,0015,'r', v_comentarios, null);
    end if;
    -- Fin Modif Ticket #1448 27/10/15
    
    lib1.array_out_add(p_array_out,0006,'r', v_id_tipo_tx, null); --ID TIPO TX para el filtro
    
    lib1.array_out_add(p_array_out,0010,'r', v_edad_paciente, null);
    lib1.array_out_add(p_array_out,0012,'r', v_id_establecimiento, null); -- id_establcimiento
    lib1.array_out_add(p_array_out,0013,'r', v_provincia_establecimiento, null); -- provincia_dsp
    lib1.array_out_add(p_array_out,0014,'r', v_tipo_tx_dsc, null); --nro id tipo tx


    /*************   ********************/
       
    raise ok1;

exception 
when ok1 then
    p_resultado :='001-OK';   
when error1 then
    p_resultado :='070-ERROR. ID_INDICACION NULO.';
when error2 then
    p_resultado := '070-ERROR. NO EXISTE INDICACION.';
when error_select then
    p_resultado := '070-ERROR AL SELECCIONAR ' || v_error_select;    

END P_RECUPERAR;

PROCEDURE P_MODIFICAR ( p_id_indicacion in NUMBER,
                        p_id_usuario in NUMBER,
                        p_array_in in tabla_array, 
                        p_array_out out tabla_array, 
                        p_resultado out varchar2
                      )
AS

    ok1     exception;
    error1  exception;
    error2  exception;
    error3  exception;
    error4  exception;
    
    rec_vistaIndicacion     v_m6_indicacion_tx_cph%rowtype;
    
    v_id_etx_a_asignar          number;
    v_etx_a_asignar             varchar2(100);
    v_id_situacion_indicacion   number;
    v_id_situacion_registro     number;
    v_id_usuario_registro       number;
    v_fecha_registro            DATE;
    v_id_trasplante             number;
    v_nro_afiliado_validador    number;
    v_nro_afiliado_a_asignar    varchar2(20);
    v_comentarios_a_asignar     varchar2(200);  
    
    
begin
   
    --Validamos los parametros de entrada 
    if p_id_indicacion is null then raise error1; end if;
    if p_id_usuario is null then raise error4; end if;
   
    begin
        select * into rec_vistaIndicacion from v_m6_indicacion_tx_cph where id_indicacion = p_id_indicacion;
        exception when no_data_found then raise error2; 
    end;
    
    /* Inicializamos las variables*/
    p_array_out := tabla_array();
    v_id_situacion_indicacion := 4;
    v_id_situacion_registro := 2;
        
    /*obtenemos las variables */
    v_id_etx_a_asignar := lib1.array_get(p_array_in,0011);
    v_comentarios_a_asignar := lib1.array_get(p_array_in,0015); 
    v_nro_afiliado_a_asignar := lib1.array_get(p_array_in,0005);
    
    
    
    if v_id_etx_a_asignar is null then 
      lib1.array_put(p_array_out,0011, 'VALOR REQUERIDO'); --Mensaje de error
      raise error3;
    end if;
    
    /* Inico Modif Chacho Ticket #1448  27/10/15
    Se valida el ingreso de un nro_afiliado y se guardan en tabla junto al commentario*/
    if v_nro_afiliado_a_asignar is null then 
      lib1.array_put(p_array_out,0005, 'VALOR REQUERIDO: INGRESAR NRO AFILIADO O DNI'); --Mensaje de error
      raise error3;
    end if;
    
     begin 
        v_nro_afiliado_validador := TO_NUMBER(v_nro_afiliado_a_asignar); 
        
        exception WHEN OTHERS 
            then lib1.array_put(p_array_out,0005, 'VALOR INCORRECTO: INGRESAR NRO AFILIADO O DNI'); --Mensaje de error
            raise error3;
      end;  

    savepoint safe; 
        --actualizamos m6_indicacion
        Update M6_INDICACION 
        SET M6_INDICACION.id_etx = v_id_etx_a_asignar, M6_INDICACION.ID_SITUACION_INDICACION = 4, 
            M6_INDICACION.id_situacion_registro = 2 , M6_INDICACION.comentario = v_comentarios_a_asignar
        WHERE M6_INDICACION.ID_INDICACION = p_id_indicacion;    
        
        Update M6_PACIENTE_FINANCIADOR
        SET M6_PACIENTE_FINANCIADOR.NRO_AFILIADO = v_nro_afiliado_a_asignar
        WHERE M6_PACIENTE_FINANCIADOR.ID_INDICACION = p_id_indicacion; 
        
        -- Fin Inico Modif Chacho Ticket #1448  27/10/15
        
        --guardamos hisotrial
        insert into M6_MOVIMIENTO_INDICACION( 
        ID_MOVIMIENTO_INDICACION, ID_INDICACION, ID_SITUACION_INDICACION, ID_ETX, ID_CAUSA_INTERRUPCION, ID_USUARIO_REGISTRO, FECHA_REGISTRO)
        values(SINTRA.NRO_ID_MOVIMIENTO_INDICACION.nextval, p_id_indicacion, v_id_situacion_indicacion, v_id_etx_a_asignar, rec_vistaIndicacion.id_causa_interrupcion, p_id_usuario, sysdate);      
        
        raise ok1;
   
exception 
  when ok1 then
      p_resultado :='001-OK';   
  when error1 then
      p_resultado :='010-ERROR. ID_PD NULO.';
  when error2  then
      p_resultado := '010-ERROR. NO EXISTE PD.';
  when error3 then
      p_resultado := '010-ERROR. ID_ETX NULO.';
   when error4  then
      p_resultado := '010-ERROR. ID_USUARIO NULO.'; 
    
  when others then
      rollback to savepoint safe;
      p_resultado := '010-ERROR DML INESPERADO.';

END P_MODIFICAR;



END PKG_LE_INDICACIONES;
/*FIN DE CUERPO DE PAQUETE*****************************************************/
/