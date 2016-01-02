/*
This is the source of a test MIC handler task that implements audio input output with a levelmeter.

Implemented by Marc (c) December 2015

*/

SECTION "MICHAND"                   // Main control section

GET     "libhdr"
GET     "manhdr"

GLOBAL {
buf
back
mix
ou
fd
}

MANIFEST {
  bufsize = 256
  bufbytes = bufsize * bytesperword

}

STATIC {

}



LET start ( init_pkt ) BE
{
  		LET hwname = "/dev/dsp"
	LET format = 16  // S8_LE
	LET channels = 1 // Mono
	LET rate = 44100 // Samples per second
    
	LET input_buf = VEC bufsize-1
	LET input_back = VEC bufsize-1
	LET input_mix = VEC bufsize-1
    LET audio_fd = 0
	LET audio_ou = 0

	buf, back := input_buf, input_back
	mix := input_mix

 set_process_name("MIC_Handler") // MW 22/12/15

  qpkt(init_pkt)  // Return startup pkt

    /*LET audio_fd := sys(Sys_sound, 1, hwname, format, channels, rate)
	LET audio_ou := sys(Sys_sound, 6, hwname, format, channels, rate)*/

    audio_fd := sys(Sys_sound, 1, hwname, format, channels, rate)
	audio_ou := sys(Sys_sound, 6, hwname, format, channels, rate)

	fd := audio_fd
	ou := audio_ou

  // Main action loop
  { LET pkt= taskwait()
	LET type, scb = pkt!pkt_type, pkt!pkt_arg1


    

	sawritef("MICHAND: received pkt %n type %n*n", pkt, type)



	/*audio_ou := ou*/



	UNLESS fd>0 DO
	{ 
		sawritef("Input device busy*n")
		abort(999)
	}

	UNLESS ou>0 DO
	{ 
		sawritef("Output device busy*n")
		abort(999)
	}

    SWITCHON type INTO
    {
      CASE 0:
        sawritef("MICHAND: first reading audio*n")
//		audioon()


				pkt!pkt_type := Action_read
		qpkt(pkt)
        returnpkt(pkt, TRUE, 0)
        LOOP

      CASE Action_read:
        sawritef("MICHAND: reading audio*n")
		audioread()

        //returnpkt(pkt, TRUE, 0)
				pkt!pkt_type := Action_write
		qpkt(pkt)
        LOOP

      CASE Action_write:
        sawritef("MICHAND: writing audio*n")
		audiowrite();
				pkt!pkt_type := Action_read
		qpkt(pkt)
        //returnpkt(pkt, TRUE, 0)
		
        LOOP

      /*CASE Action_findinoutput:
        sawritef("MICHAND: starting inout mode*n")
        returnpkt(pkt, TRUE, 0)
        LOOP*/

      DEFAULT:  // Unknown or unimplemented operation
           sawritef("MICHAND: illegal op %n scb %n*n", type, scb)
           abort(306)
           returnpkt(pkt, 0, 0)
           LOOP
    }
  } REPEAT
}

AND audiowrite() = VALOF
{
	LET let = 0
	LET hwname = "/dev/dsp"
	LET format = 16  // S8_LE
	LET channels = 1 // Mono
	LET rate = 44100 // Samples per second

	sawritef("ou = %n*n", ou)

	//let := sys(Sys_sound, 7, ou, buf, bufbytes, 0)
	sawritef("played*n")
}

AND audioread() = VALOF
{
	LET audio_fd = 0

	LET hwname = "/dev/dsp"
	LET format = 16  // S8_LE
	LET channels = 1 // Mono
	LET rate = 44100 // Samples per second

	LET p = 0.0
	LET b = 0
	LET a = 0
	LET h = 0
	LET len = 1
	LET let = 0

	//LET w_pkt = VEC pkt_type

	//pkt!pkt_link, pkt!pkt_taskid, pkt!pkt_type, pkt!pkt_arg1 := notinuse, 6, Action_write, Action_write


	sawritef("tstmic entered*n")

	sawritef("sys(Sys_sound, 0,...) => %n*n", sys(Sys_sound, 0, 11, 22, 33, 44))

	/*UNLESS sys(Sys_sound, 0, 11, 22, 33, 44) DO
	{ 
		writef("Sound not available*n")
		RESULTIS 0
	}*/

	sawritef("Trying to open device %s*n", hwname)

	/*audio_fd := sys(Sys_sound, 1, hwname, format, channels, rate)*/

	sawritef("fd = %n*n", fd)



	/*WHILE len>0 DO
	{*/
		len := sys(Sys_sound, 4, fd, buf, bufbytes, 0)
		let := sys(Sys_sound, 7, ou, buf, bufbytes, 0)
		sawritef("Next*n")

		IF len > 0 DO
		{


			FOR i = 0 TO bufsize-1 DO
			{ 
				p:= back!i

				/*TEST p>0 THEN
				{
					a := b / 2048
				}
				ELSE
				{
					a := -b / 2048
				}
				IF a>h DO
				{
					h := a
				}*/

				mix!i := p + buf!i// + (buf!i << 16) / #x1_0000

				/*TEST b>0 THEN
				{
					back!i := (back!i) - (back!i / 100) + (buf!i << 16) / #x1_0000
				}
				ELSE
				{
					back!i := (back!i) + (back!i / 100) + (buf!i << 16) / #x1_0000
				}*/

				//back!i := (back!i) - 100 + (buf!i << 16) / #x1_0000 // buf!i  
			}

			FOR i = 0 TO bufsize-1 DO
			{
				back!i := ((buf!i << 16) / #x1_0000)
			}



			/*let := sys(Sys_sound, 7, audio_ou, mix, len, 0)*/

			/*FOR i = 0 TO bufsize-1 DO
			{ 
				b := (buf!i << 16) / #x1_0000
			  	 
				TEST b>0 THEN
				{
					a := b / 2048
				}
				ELSE
				{
					a := -b / 2048
				}
				IF a>h DO
				{
					h := a
				}
			}*/

			/*sawritef(">>%n", p)*/
			/*IF h > 0 DO
			{*/
				/*sawritef('*c')*/
				/*wrch('*c')*/
				/*writef("*b*b*b*b*b*b*b*b*b*b*b*b*b*b*b*b*b*b")*/
				/*SWITCHON h INTO
				{
					DEFAULT:sawritef("[                ]")
					ENDCASE
					CASE 1:sawritef("[-               ]")
					ENDCASE
					CASE 2:sawritef("[--              ]")
					ENDCASE
					CASE 3:sawritef("[---             ]")
					ENDCASE
					CASE 4:sawritef("[----            ]")
					ENDCASE
					CASE 5:sawritef("[-----           ]")
					ENDCASE
					CASE 6:sawritef("[------          ]")
					ENDCASE
					CASE 7:sawritef("[-------         ]")
					ENDCASE
					CASE 8:sawritef("[--------        ]")
					ENDCASE
					CASE 9:sawritef("[---------       ]")
					ENDCASE
					CASE 10:sawritef("[----------      ]")
					ENDCASE
					CASE 11:sawritef("[-----------     ]")
					ENDCASE
					CASE 12:sawritef("[------------    ]")
					ENDCASE
					CASE 13:sawritef("[-------------   ]")
					ENDCASE
					CASE 14:sawritef("[--------------  ]")
					ENDCASE
					CASE 15:sawritef("[--------------- ]")
					ENDCASE
					CASE 16:sawritef("[----------------]")
					ENDCASE
				}*/
				
				/*h := 0*/
			/*}*/
		}
	
sawritef("Dun*n")
	/*}*/

  /*sawritef("Closing audio_fd*n")

  audio_fd := sys(Sys_sound, 5, audio_fd, 0, 0, 0)

  sawritef("return code = %n*n", audio_fd)*/
}

