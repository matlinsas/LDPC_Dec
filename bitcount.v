module bitcount(din, cnt);
parameter data_w = 2304;
parameter count_w = 12;

input [data_w-1:0] din;
output [count_w-1:0] cnt;

function [3:0] cnt_lut;
	input x;
	output c;
	begin
		case(x)
			default:c=0;
			1:c=1;
			2:c=1;
			3:c=2;
			4:c=1;
			5:c=2;
			6:c=2;
			7:c=3;
			8:c=1;
			9:c=2;
			10:c=2;
			11:c=3;
			12:c=2;
			13:c=3;
			14:c=3;
			15:c=4;
			16:c=1;
			17:c=2;
			18:c=2;
			19:c=3;
			20:c=2;
			21:c=3;
			22:c=3;
			23:c=4;
			24:c=2;
			25:c=3;
			26:c=3;
			27:c=4;
			28:c=3;
			29:c=4;
			30:c=4;
			31:c=5;
			32:c=1;
			33:c=2;
			34:c=2;
			35:c=3;
			36:c=2;
			37:c=3;
			38:c=3;
			39:c=4;
			40:c=2;
			41:c=3;
			42:c=3;
			43:c=4;
			44:c=3;
			45:c=4;
			46:c=4;
			47:c=5;
			48:c=2;
			49:c=3;
			50:c=3;
			51:c=4;
			52:c=3;
			53:c=4;
			54:c=4;
			55:c=5;
			56:c=3;
			57:c=4;
			58:c=4;
			59:c=5;
			60:c=4;
			61:c=5;
			62:c=5;
			63:c=6;
			64:c=1;
			65:c=2;
			66:c=2;
			67:c=3;
			68:c=2;
			69:c=3;
			70:c=3;
			71:c=4;
			72:c=2;
			73:c=3;
			74:c=3;
			75:c=4;
			76:c=3;
			77:c=4;
			78:c=4;
			79:c=5;
			80:c=2;
			81:c=3;
			82:c=3;
			83:c=4;
			84:c=3;
			85:c=4;
			86:c=4;
			87:c=5;
			88:c=3;
			89:c=4;
			90:c=4;
			91:c=5;
			92:c=4;
			93:c=5;
			94:c=5;
			95:c=6;
			96:c=2;
			97:c=3;
			98:c=3;
			99:c=4;
			100:c=3;
			101:c=4;
			102:c=4;
			103:c=5;
			104:c=3;
			105:c=4;
			106:c=4;
			107:c=5;
			108:c=4;
			109:c=5;
			110:c=5;
			111:c=6;
			112:c=3;
			113:c=4;
			114:c=4;
			115:c=5;
			116:c=4;
			117:c=5;
			118:c=5;
			119:c=6;
			120:c=4;
			121:c=5;
			122:c=5;
			123:c=6;
			124:c=5;
			125:c=6;
			126:c=6;
			127:c=7;
			128:c=1;
			129:c=2;
			130:c=2;
			131:c=3;
			132:c=2;
			133:c=3;
			134:c=3;
			135:c=4;
			136:c=2;
			137:c=3;
			138:c=3;
			139:c=4;
			140:c=3;
			141:c=4;
			142:c=4;
			143:c=5;
			144:c=2;
			145:c=3;
			146:c=3;
			147:c=4;
			148:c=3;
			149:c=4;
			150:c=4;
			151:c=5;
			152:c=3;
			153:c=4;
			154:c=4;
			155:c=5;
			156:c=4;
			157:c=5;
			158:c=5;
			159:c=6;
			160:c=2;
			161:c=3;
			162:c=3;
			163:c=4;
			164:c=3;
			165:c=4;
			166:c=4;
			167:c=5;
			168:c=3;
			169:c=4;
			170:c=4;
			171:c=5;
			172:c=4;
			173:c=5;
			174:c=5;
			175:c=6;
			176:c=3;
			177:c=4;
			178:c=4;
			179:c=5;
			180:c=4;
			181:c=5;
			182:c=5;
			183:c=6;
			184:c=4;
			185:c=5;
			186:c=5;
			187:c=6;
			188:c=5;
			189:c=6;
			190:c=6;
			191:c=7;
			192:c=2;
			193:c=3;
			194:c=3;
			195:c=4;
			196:c=3;
			197:c=4;
			198:c=4;
			199:c=5;
			200:c=3;
			201:c=4;
			202:c=4;
			203:c=5;
			204:c=4;
			205:c=5;
			206:c=5;
			207:c=6;
			208:c=3;
			209:c=4;
			210:c=4;
			211:c=5;
			212:c=4;
			213:c=5;
			214:c=5;
			215:c=6;
			216:c=4;
			217:c=5;
			218:c=5;
			219:c=6;
			220:c=5;
			221:c=6;
			222:c=6;
			223:c=7;
			224:c=3;
			225:c=4;
			226:c=4;
			227:c=5;
			228:c=4;
			229:c=5;
			230:c=5;
			231:c=6;
			232:c=4;
			233:c=5;
			234:c=5;
			235:c=6;
			236:c=5;
			237:c=6;
			238:c=6;
			239:c=7;
			240:c=4;
			241:c=5;
			242:c=5;
			243:c=6;
			244:c=5;
			245:c=6;
			246:c=6;
			247:c=7;
			248:c=5;
			249:c=6;
			250:c=6;
			251:c=7;
			252:c=6;
			253:c=7;
			254:c=7;
			255:c=8;
		endcase
	end
endfunction

endmodule 
