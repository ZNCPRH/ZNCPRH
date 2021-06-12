*&---------------------------------------------------------------------*
*& Report ZNCPRH_P999
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zncprh_p999.

TABLES: e070.

* Selection screen *
SELECT-OPTIONS: s_req FOR e070-trkorr.
DATA:  p_trkorr LIKE e070-trkorr.
PARAMETERS p_lpath LIKE draw-filep OBLIGATORY DEFAULT 'C:\Users\P1362\Desktop'.

SELECTION-SCREEN SKIP.

PARAMETERS p_down RADIOBUTTON GROUP func DEFAULT 'X'.
PARAMETERS p_up RADIOBUTTON GROUP func.

* Global data *
TYPE-POOLS sabc.

DATA pos TYPE i.
DATA temp TYPE c.

DATA path LIKE draw-filep.
DATA path_cofile LIKE draw-filep.
DATA path_data LIKE draw-filep.
DATA path_bin LIKE draw-filep.

DATA fk LIKE draw-filep.
DATA fr LIKE draw-filep.
DATA fd LIKE draw-filep.

DATA separator TYPE c.

* Complete local path *
AT SELECTION-SCREEN.
  pos  = strlen( p_lpath ) - 1.
  temp =  p_lpath+pos(1).
  CHECK NOT temp = '\'.
  CONCATENATE p_lpath '\' INTO p_lpath.

START-OF-SELECTION.

  LOOP AT s_req.
    CLEAR: p_trkorr.
    MOVE s_req-low TO p_trkorr.
* Determine transport base directory *
    CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_TRANS'
                       ID 'VALUE' FIELD  path.
*path = '\\bekotest\saploc\trans'.

* Determine file/path separator *
    IF sy-opsys = 'Windows NT'.
      separator = '\'.
    ELSE.
      separator = '/'.
    ENDIF.

* Determine transport directories *
    CONCATENATE path separator 'cofiles' separator INTO path_cofile.
    CONCATENATE path separator 'data'    separator INTO path_data.
    CONCATENATE path separator 'data'    separator INTO path_bin.
    WRITE  / 'Paths:'.
    WRITE: /  path_cofile,path_data,path_bin.
    SKIP.

* Build filenames *
    CONCATENATE p_trkorr+3(7) p_trkorr+0(3) INTO fk SEPARATED BY '.'.
    CONCATENATE 'R' p_trkorr+4(6) '.' p_trkorr+0(3) INTO fr.
    CONCATENATE 'D' p_trkorr+4(6) '.' p_trkorr+0(3) INTO fd.

* Up- or download transport request *
    IF p_down = 'X'.
      PERFORM download USING path_cofile p_lpath fk.
      PERFORM download USING path_data   p_lpath fr.
      PERFORM download USING path_data   p_lpath fd.
    ELSE.
      PERFORM upload USING p_lpath path_cofile fk.
      PERFORM upload USING p_lpath path_data   fr.
      PERFORM upload USING p_lpath path_data   fd.
    ENDIF.
  ENDLOOP.
* Download files *
FORM download USING VALUE(srcpath) LIKE draw-filep
                    VALUE(dstpath) LIKE draw-filep
                    VALUE(file)    LIKE draw-filep.
  DATA BEGIN OF buffer OCCURS 0.
  DATA   data(1024) TYPE x.
  DATA END OF buffer.

  DATA filename TYPE rlgrap-filename.
  DATA reclen   TYPE i.
  DATA filelen  TYPE i.

* Read input file *
  CONCATENATE srcpath file INTO filename.
  OPEN DATASET filename FOR INPUT IN BINARY MODE.
  CHECK sy-subrc = 0.
  WHILE sy-subrc = 0.
    READ DATASET filename INTO buffer LENGTH reclen.
    filelen = filelen + reclen.
    APPEND buffer.
  ENDWHILE.
  CLOSE DATASET filename.

* Download file *
  CONCATENATE dstpath file INTO filename.
  CALL FUNCTION 'WS_DOWNLOAD'
    EXPORTING
      bin_filesize = filelen
      filename     = filename
      filetype     = 'BIN'
    TABLES
      data_tab     = buffer
    EXCEPTIONS
      OTHERS       = 1.
  CHECK sy-subrc = 0.
  WRITE: / 'Download:',(150) file.
ENDFORM.

* Upload file *
FORM upload USING VALUE(srcpath) LIKE draw-filep
                  VALUE(dstpath) LIKE draw-filep
                  VALUE(file)    LIKE draw-filep.
  DATA BEGIN OF buffer OCCURS 0.
  DATA   data(1024) TYPE x.
  DATA END OF buffer.

  DATA filename TYPE rlgrap-filename.
  DATA reclen   TYPE i.
  DATA filelen  TYPE i.
  DATA result   TYPE c.

* Check if file exists *
  CONCATENATE srcpath file INTO filename.
  CALL FUNCTION 'WS_QUERY'
    EXPORTING
      filename = filename
      query    = 'FE'
    IMPORTING
      return   = result
    EXCEPTIONS
      OTHERS   = 1.
  CHECK sy-subrc = 0 AND result = '1'.

* Upload file *
  CALL FUNCTION 'WS_UPLOAD'
    EXPORTING
      filename   = filename
      filetype   = 'BIN'
    IMPORTING
      filelength = filelen
    TABLES
      data_tab   = buffer
    EXCEPTIONS
      OTHERS     = 1.

* Write file to server *
  CONCATENATE dstpath file INTO filename.
  OPEN DATASET filename FOR OUTPUT IN BINARY MODE.
  CHECK sy-subrc = 0.
  LOOP AT buffer.
    DESCRIBE FIELD buffer-data LENGTH reclen IN BYTE MODE.
    IF filelen > reclen.
      filelen = filelen - reclen.
    ELSE.
      reclen = filelen.
    ENDIF.
    TRANSFER buffer TO filename LENGTH reclen.
  ENDLOOP.
  CLOSE DATASET filename.
  WRITE: / 'Upload:',(150)file.
ENDFORM.
