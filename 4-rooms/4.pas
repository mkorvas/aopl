program Rooms;

uses strings, sysutils;

const
	codeLen = 5;
	asciimin = 0;
	asciimax = 127;

type
	codeT = array[1..codeLen] of char;
	lettercountsT = array[asciimin..asciimax] of integer;
	parseStateT = (letters, nums, lbrace, incode, rbrace);

var
	lineno, checksum: longint;
	roomcode: string;
 
function checkroom(roomcode: string): longint;
var
	code: codeT;
	lettercounts: lettercountsT;
	ltr, codeltr: char;
	ltridx, ltrord, codeIdx, ltrcount: integer;
	parseState: parseStateT;
	weightstr: string;

begin

	checkroom := -1;

	weightstr := '';
	for ltrord := asciimin to asciimax do
		lettercounts[ltrord] := 0;
	for codeIdx := 1 to codeLen do
		code[codeIdx] := #0;

	codeIdx := 0;
	parseState := letters;
	for ltridx := 1 to length(roomcode) do
		begin
			ltr := roomcode[ltridx];

			{ Update parseState. }
			case (parseState) of
				letters:
					if (ltr >= '0') and (ltr <= '9') then
						parseState := nums;
				nums:
					if ltr = '[' then
						begin
							parseState := lbrace;
							continue;
						end;
				lbrace:
					parseState := incode;
				incode:
					if ltr = ']' then
						begin
							parseState := rbrace;
							continue;
						end;
				rbrace:
					continue;
			end;

			{ Record this letter. }
			if parseState = letters then
				begin
					if (ltr >= 'a') and (ltr <= 'z') then
						inc(lettercounts[ord(ltr)]);
				end
			else if parseState = nums then
				weightstr := weightstr + ltr
			else if parseState = incode then
				begin
					inc(codeIdx);
					if codeIdx <= codeLen then
						code[codeIdx] := ltr;
				end;

		end;

	if codeIdx <> codeLen then
		{ writeln('decoy: wrong code length, ', codeIdx) }
		checkroom := 0
	else
		begin
			for codeIdx := 1 to codeLen do
				begin
					codeltr := code[codeidx];
					ltrcount := lettercounts[ord(codeltr)];
					if ltrcount = 0 then
						begin
							{ writeln('decoy: no occurrences of ', codeltr) }
							checkroom := 0;
							break;
						end
					else
						begin
							for ltrord := asciimin to asciimax do
								begin
									if lettercounts[ltrord] > ltrcount then
										begin
											{ writeln(chr(ltrord), ':', lettercounts[ltrord]); }
											{ writeln('decoy: ', chr(ltrord), ' more frequent than ', codeltr); }
											checkroom := 0;
											break;
										end
									else if (lettercounts[ltrord] >= ltrcount) and
													(ltrord < ord(codeltr)) then
										begin
											{ writeln('decoy: ', chr(ltrord), ' earlier in abc than ', codeltr); }
											checkroom := 0;
											break;
										end;
								end;
						end;
					lettercounts[ord(codeltr)] := 0;

					if checkroom = 0 then break;
				end;
		end;

		if checkroom = -1 then
			begin
				{ DEBUGGING }
				{ writeln(lineno, ' ', weightstr); }
				checkroom := strtoint(weightstr)
			end
		else
			{ DEBUGGING }
			{ writeln(lineno, ' ', 0); }
end;  { checkroom }

begin

	checksum := 0;
	lineno := 0;
	while not eof() do
		begin
			readln(roomcode);
			inc(lineno);
			checksum := checksum + checkroom(roomcode);
		end;
	writeln(checksum);

end.
