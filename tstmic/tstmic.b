SECTION "tstmic"

GET "libhdr"

GLOBAL {
}

MANIFEST {
  bufsize = 256
  bufbytes = bufsize * bytesperword
}

LET start() = VALOF
{
	LET audio_fd = 0
	LET audio_ou = 0
	LET hwname = "/dev/dsp"
	LET format = 16  // S8_LE
	LET channels = 1 // Mono
	LET rate = 44100 // Samples per second
	LET buf = VEC bufsize-1

	LET b = 0
	LET a = 0
	LET h = 0
	LET len = 1
	LET let = 0

	UNLESS sys(Sys_sound, 0, 11, 22, 33, 44) DO
	{ 
		writef("Sound not available*n")
		RESULTIS 0
	}

	//writef("Trying to open device %s*n", hwname)

	audio_fd := sys(Sys_sound, 1, hwname, format, channels, rate)

	//writef("audio_fd = %n*n", audio_fd)

	UNLESS audio_fd>0 DO
	{ 
		writef("Input device busy*n")
		RESULTIS 0
	}

	audio_ou := sys(Sys_sound, 6, hwname, format, channels, rate)

	//writef("audio_ou = %n*n", audio_ou)

	UNLESS audio_ou>0 DO
	{ 
		writef("Output device busy*n")
		RESULTIS 0
	}

	WHILE len>0 DO
	{
		len := sys(Sys_sound, 4, audio_fd, buf, bufbytes, 0)
		
		IF len > 0 DO
		{
			let := sys(Sys_sound, 7, audio_ou, buf, len, 0)

			FOR i = 0 TO bufsize-1 DO
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
			}

			wrch('*n')

			SWITCHON h INTO
			{
				DEFAULT:writef("[                ]")
				ENDCASE
				CASE 1:writef("[-               ]")
				ENDCASE
				CASE 2:writef("[--              ]")
				ENDCASE
				CASE 3:writef("[---             ]")
				ENDCASE
				CASE 4:writef("[----            ]")
				ENDCASE
				CASE 5:writef("[-----           ]")
				ENDCASE
				CASE 6:writef("[------          ]")
				ENDCASE
				CASE 7:writef("[-------         ]")
				ENDCASE
				CASE 8:writef("[--------        ]")
				ENDCASE
				CASE 9:writef("[---------       ]")
				ENDCASE
				CASE 10:writef("[----------      ]")
				ENDCASE
				CASE 11:writef("[-----------     ]")
				ENDCASE
				CASE 12:writef("[------------    ]")
				ENDCASE
				CASE 13:writef("[-------------   ]")
				ENDCASE
				CASE 14:writef("[--------------  ]")
				ENDCASE
				CASE 15:writef("[--------------- ]")
				ENDCASE
				CASE 16:writef("[----------------]")
				ENDCASE
			}
			/* wrch('*c') */  // not working
			h := 0
		}
	
	}

  writef("Closing audio_fd*n")

  audio_fd := sys(Sys_sound, 5, audio_fd, 0, 0, 0)

  writef("return code = %n*n", audio_fd)

  RESULTIS 0
}
