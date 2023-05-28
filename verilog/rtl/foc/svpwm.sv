
// 模块：svpwm
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// 功能：7 段式 SVPWM 生成器（调制器） 
// 输入：定子极坐标系下的电压矢量 Vsρ, Vsθ
// 输出：PWM使能信号 pwm_en
//       3相PWM信号 pwm_a, pwm_b, pwm_c
// 说明：该模块产生的 PWM 的频率是 clk 频率 / 2048。例如 clk 为 36.864MHz ，则 PWM 的频率为 36.864MHz / 2048 = 18kHz

module svpwm (
    input  wire        rstn,
    input  wire        clk,
    input  wire [ 8:0] v_amp,                       // svpwm 的最大电压矢量的幅值
    input  wire [11:0] v_rho,                       // 定子极坐标系下的电压矢量的幅值 Vsρ
    input  wire [11:0] v_theta,                     // 定子极坐标系下的电压矢量的角度 Vsθ
    output reg         pwm_en, pwm_a, pwm_b, pwm_c  // PWM使能信号 pwm_en, 3相PWM信号 pwm_a, pwm_b, pwm_c
);

localparam ROM_LATENCY = 11'd4;

reg  [10:0] cnt;
reg  [11:0] rom_x;
reg         rom_sy;
reg  [ 8:0] rom_y;
reg  [ 8:0] mul_i1;
reg  [11:0] mul_i2;
wire [20:0] mul_y = mul_i1 * mul_i2;
reg  [11:0] mul_o;
reg         sya, syb, syc;
reg  [ 8:0] ya, yb;
reg  [ 9:0] pwma_duty, pwmb_duty, pwmc_duty;
reg  [10:0] pwma_lb, pwma_ub, pwmb_lb, pwmb_ub, pwmc_lb, pwmc_ub;
reg         pwm_act;

always @ (posedge clk or negedge rstn)
    if(~rstn)
        mul_o <= '0;
    else
        mul_o <= mul_y[20:9];

always @ (posedge clk or negedge rstn)
    if(~rstn)
        cnt <= '0;
    else
        cnt <= cnt + 11'd1;

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        rom_x <= '0;
        mul_i1 <= '0;
        mul_i2 <= '0;
        {sya, syb, syc} <= '0;
        {ya, yb} <= '0;
        {pwma_duty, pwmb_duty, pwmc_duty} <= '0;
        {pwma_lb, pwma_ub, pwmb_lb, pwmb_ub, pwmc_lb, pwmc_ub} <= '0;
        pwm_act <= 1'b0;
    end else begin
        if(cnt==11'd2041-ROM_LATENCY) begin
            rom_x <= v_theta;
            mul_i1 <= v_amp;
            mul_i2 <= v_rho;
        end else if(cnt==11'd2042-ROM_LATENCY) begin
            rom_x <= rom_x - 12'd1365;
        end else if(cnt==11'd2043-ROM_LATENCY) begin
            rom_x <= rom_x - 12'd1365;
            mul_i2 <= mul_o + 12'd8;
        end else if(cnt==11'd2042) begin
            mul_i1 <= rom_y;
            sya <= rom_sy;
        end else if(cnt==11'd2043) begin
            mul_i1 <= rom_y;
            syb <= rom_sy;
        end else if(cnt==11'd2044) begin
            mul_i1 <= rom_y;
            syc <= rom_sy;
            ya <= mul_o[11:3];
        end else if(cnt==11'd2045) begin
            yb <= mul_o[11:3];
        end else if(cnt==11'd2046) begin
            pwma_duty <= sya ? 10'd512-{1'b0, ya        } : 10'd512+{1'b0, ya        };
            pwmb_duty <= syb ? 10'd512-{1'b0, yb        } : 10'd512+{1'b0, yb        };
            pwmc_duty <= syc ? 10'd512-{1'b0,mul_o[11:3]} : 10'd512+{1'b0,mul_o[11:3]};
        end else if(cnt==11'd2047) begin
            pwma_lb <= 11'd0 + {1'b0, pwma_duty};
            pwma_ub <= 11'd0 - {1'b0, pwma_duty};
            pwmb_lb <= 11'd0 + {1'b0, pwmb_duty};
            pwmb_ub <= 11'd0 - {1'b0, pwmb_duty};
            pwmc_lb <= 11'd0 + {1'b0, pwmc_duty};
            pwmc_ub <= 11'd0 - {1'b0, pwmc_duty};
            pwm_act <= 1'b1;
        end
    end

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        pwm_en <= 1'b0;
        pwm_a <= 1'b1;
        pwm_b <= 1'b1;
        pwm_c <= 1'b1;
    end else begin
        pwm_en <= pwm_act;
        pwm_a <= ~pwm_act || cnt<=pwma_lb || cnt>pwma_ub;
        pwm_b <= ~pwm_act || cnt<=pwmb_lb || cnt>pwmb_ub;
        pwm_c <= ~pwm_act || cnt<=pwmc_lb || cnt>pwmc_ub;
    end



reg [11:0] x1;
reg [ 9:0] x2;
reg        s2;
reg        z2;
reg [ 8:0] y3;
reg        s3;
reg        z3;

always @ (posedge clk)
    if(rom_x >= 12'd2048)
        x1 <= 12'd0 - rom_x;
    else
        x1 <= rom_x;

always @ (posedge clk) begin
    z2 <= x1 == 12'd1024;
    if( x1 <= 12'd1024 ) begin
        x2 <= x1[9:0];
        s2 <= 1'b0;
    end else begin
        x2 <= 10'd0 - x1[9:0];
        s2 <= 1'b1;
    end
end

always @ (posedge clk) begin
    z3 <= z2;
    s3 <= s2;
end

always @ (posedge clk) begin
    rom_sy <= s3;
    if(z3)
        rom_y <= 9'd0;
    else
        rom_y <= y3;
end

always @ (posedge clk)
case(x2)
10'd0:y3<=9'd442;
10'd1:y3<=9'd443;
10'd2:y3<=9'd443;
10'd3:y3<=9'd444;
10'd4:y3<=9'd444;
10'd5:y3<=9'd444;
10'd6:y3<=9'd445;
10'd7:y3<=9'd445;
10'd8:y3<=9'd446;
10'd9:y3<=9'd446;
10'd10:y3<=9'd446;
10'd11:y3<=9'd447;
10'd12:y3<=9'd447;
10'd13:y3<=9'd447;
10'd14:y3<=9'd448;
10'd15:y3<=9'd448;
10'd16:y3<=9'd449;
10'd17:y3<=9'd449;
10'd18:y3<=9'd449;
10'd19:y3<=9'd450;
10'd20:y3<=9'd450;
10'd21:y3<=9'd450;
10'd22:y3<=9'd451;
10'd23:y3<=9'd451;
10'd24:y3<=9'd452;
10'd25:y3<=9'd452;
10'd26:y3<=9'd452;
10'd27:y3<=9'd453;
10'd28:y3<=9'd453;
10'd29:y3<=9'd453;
10'd30:y3<=9'd454;
10'd31:y3<=9'd454;
10'd32:y3<=9'd454;
10'd33:y3<=9'd455;
10'd34:y3<=9'd455;
10'd35:y3<=9'd456;
10'd36:y3<=9'd456;
10'd37:y3<=9'd456;
10'd38:y3<=9'd457;
10'd39:y3<=9'd457;
10'd40:y3<=9'd457;
10'd41:y3<=9'd458;
10'd42:y3<=9'd458;
10'd43:y3<=9'd458;
10'd44:y3<=9'd459;
10'd45:y3<=9'd459;
10'd46:y3<=9'd459;
10'd47:y3<=9'd460;
10'd48:y3<=9'd460;
10'd49:y3<=9'd460;
10'd50:y3<=9'd461;
10'd51:y3<=9'd461;
10'd52:y3<=9'd461;
10'd53:y3<=9'd462;
10'd54:y3<=9'd462;
10'd55:y3<=9'd462;
10'd56:y3<=9'd463;
10'd57:y3<=9'd463;
10'd58:y3<=9'd463;
10'd59:y3<=9'd464;
10'd60:y3<=9'd464;
10'd61:y3<=9'd464;
10'd62:y3<=9'd465;
10'd63:y3<=9'd465;
10'd64:y3<=9'd465;
10'd65:y3<=9'd466;
10'd66:y3<=9'd466;
10'd67:y3<=9'd466;
10'd68:y3<=9'd467;
10'd69:y3<=9'd467;
10'd70:y3<=9'd467;
10'd71:y3<=9'd468;
10'd72:y3<=9'd468;
10'd73:y3<=9'd468;
10'd74:y3<=9'd469;
10'd75:y3<=9'd469;
10'd76:y3<=9'd469;
10'd77:y3<=9'd470;
10'd78:y3<=9'd470;
10'd79:y3<=9'd470;
10'd80:y3<=9'd470;
10'd81:y3<=9'd471;
10'd82:y3<=9'd471;
10'd83:y3<=9'd471;
10'd84:y3<=9'd472;
10'd85:y3<=9'd472;
10'd86:y3<=9'd472;
10'd87:y3<=9'd473;
10'd88:y3<=9'd473;
10'd89:y3<=9'd473;
10'd90:y3<=9'd473;
10'd91:y3<=9'd474;
10'd92:y3<=9'd474;
10'd93:y3<=9'd474;
10'd94:y3<=9'd475;
10'd95:y3<=9'd475;
10'd96:y3<=9'd475;
10'd97:y3<=9'd475;
10'd98:y3<=9'd476;
10'd99:y3<=9'd476;
10'd100:y3<=9'd476;
10'd101:y3<=9'd477;
10'd102:y3<=9'd477;
10'd103:y3<=9'd477;
10'd104:y3<=9'd477;
10'd105:y3<=9'd478;
10'd106:y3<=9'd478;
10'd107:y3<=9'd478;
10'd108:y3<=9'd479;
10'd109:y3<=9'd479;
10'd110:y3<=9'd479;
10'd111:y3<=9'd479;
10'd112:y3<=9'd480;
10'd113:y3<=9'd480;
10'd114:y3<=9'd480;
10'd115:y3<=9'd480;
10'd116:y3<=9'd481;
10'd117:y3<=9'd481;
10'd118:y3<=9'd481;
10'd119:y3<=9'd482;
10'd120:y3<=9'd482;
10'd121:y3<=9'd482;
10'd122:y3<=9'd482;
10'd123:y3<=9'd483;
10'd124:y3<=9'd483;
10'd125:y3<=9'd483;
10'd126:y3<=9'd483;
10'd127:y3<=9'd484;
10'd128:y3<=9'd484;
10'd129:y3<=9'd484;
10'd130:y3<=9'd484;
10'd131:y3<=9'd485;
10'd132:y3<=9'd485;
10'd133:y3<=9'd485;
10'd134:y3<=9'd485;
10'd135:y3<=9'd486;
10'd136:y3<=9'd486;
10'd137:y3<=9'd486;
10'd138:y3<=9'd486;
10'd139:y3<=9'd487;
10'd140:y3<=9'd487;
10'd141:y3<=9'd487;
10'd142:y3<=9'd487;
10'd143:y3<=9'd488;
10'd144:y3<=9'd488;
10'd145:y3<=9'd488;
10'd146:y3<=9'd488;
10'd147:y3<=9'd488;
10'd148:y3<=9'd489;
10'd149:y3<=9'd489;
10'd150:y3<=9'd489;
10'd151:y3<=9'd489;
10'd152:y3<=9'd490;
10'd153:y3<=9'd490;
10'd154:y3<=9'd490;
10'd155:y3<=9'd490;
10'd156:y3<=9'd490;
10'd157:y3<=9'd491;
10'd158:y3<=9'd491;
10'd159:y3<=9'd491;
10'd160:y3<=9'd491;
10'd161:y3<=9'd492;
10'd162:y3<=9'd492;
10'd163:y3<=9'd492;
10'd164:y3<=9'd492;
10'd165:y3<=9'd492;
10'd166:y3<=9'd493;
10'd167:y3<=9'd493;
10'd168:y3<=9'd493;
10'd169:y3<=9'd493;
10'd170:y3<=9'd493;
10'd171:y3<=9'd494;
10'd172:y3<=9'd494;
10'd173:y3<=9'd494;
10'd174:y3<=9'd494;
10'd175:y3<=9'd494;
10'd176:y3<=9'd495;
10'd177:y3<=9'd495;
10'd178:y3<=9'd495;
10'd179:y3<=9'd495;
10'd180:y3<=9'd495;
10'd181:y3<=9'd496;
10'd182:y3<=9'd496;
10'd183:y3<=9'd496;
10'd184:y3<=9'd496;
10'd185:y3<=9'd496;
10'd186:y3<=9'd497;
10'd187:y3<=9'd497;
10'd188:y3<=9'd497;
10'd189:y3<=9'd497;
10'd190:y3<=9'd497;
10'd191:y3<=9'd497;
10'd192:y3<=9'd498;
10'd193:y3<=9'd498;
10'd194:y3<=9'd498;
10'd195:y3<=9'd498;
10'd196:y3<=9'd498;
10'd197:y3<=9'd499;
10'd198:y3<=9'd499;
10'd199:y3<=9'd499;
10'd200:y3<=9'd499;
10'd201:y3<=9'd499;
10'd202:y3<=9'd499;
10'd203:y3<=9'd500;
10'd204:y3<=9'd500;
10'd205:y3<=9'd500;
10'd206:y3<=9'd500;
10'd207:y3<=9'd500;
10'd208:y3<=9'd500;
10'd209:y3<=9'd500;
10'd210:y3<=9'd501;
10'd211:y3<=9'd501;
10'd212:y3<=9'd501;
10'd213:y3<=9'd501;
10'd214:y3<=9'd501;
10'd215:y3<=9'd501;
10'd216:y3<=9'd502;
10'd217:y3<=9'd502;
10'd218:y3<=9'd502;
10'd219:y3<=9'd502;
10'd220:y3<=9'd502;
10'd221:y3<=9'd502;
10'd222:y3<=9'd502;
10'd223:y3<=9'd503;
10'd224:y3<=9'd503;
10'd225:y3<=9'd503;
10'd226:y3<=9'd503;
10'd227:y3<=9'd503;
10'd228:y3<=9'd503;
10'd229:y3<=9'd503;
10'd230:y3<=9'd504;
10'd231:y3<=9'd504;
10'd232:y3<=9'd504;
10'd233:y3<=9'd504;
10'd234:y3<=9'd504;
10'd235:y3<=9'd504;
10'd236:y3<=9'd504;
10'd237:y3<=9'd504;
10'd238:y3<=9'd505;
10'd239:y3<=9'd505;
10'd240:y3<=9'd505;
10'd241:y3<=9'd505;
10'd242:y3<=9'd505;
10'd243:y3<=9'd505;
10'd244:y3<=9'd505;
10'd245:y3<=9'd505;
10'd246:y3<=9'd506;
10'd247:y3<=9'd506;
10'd248:y3<=9'd506;
10'd249:y3<=9'd506;
10'd250:y3<=9'd506;
10'd251:y3<=9'd506;
10'd252:y3<=9'd506;
10'd253:y3<=9'd506;
10'd254:y3<=9'd506;
10'd255:y3<=9'd507;
10'd256:y3<=9'd507;
10'd257:y3<=9'd507;
10'd258:y3<=9'd507;
10'd259:y3<=9'd507;
10'd260:y3<=9'd507;
10'd261:y3<=9'd507;
10'd262:y3<=9'd507;
10'd263:y3<=9'd507;
10'd264:y3<=9'd507;
10'd265:y3<=9'd507;
10'd266:y3<=9'd508;
10'd267:y3<=9'd508;
10'd268:y3<=9'd508;
10'd269:y3<=9'd508;
10'd270:y3<=9'd508;
10'd271:y3<=9'd508;
10'd272:y3<=9'd508;
10'd273:y3<=9'd508;
10'd274:y3<=9'd508;
10'd275:y3<=9'd508;
10'd276:y3<=9'd508;
10'd277:y3<=9'd509;
10'd278:y3<=9'd509;
10'd279:y3<=9'd509;
10'd280:y3<=9'd509;
10'd281:y3<=9'd509;
10'd282:y3<=9'd509;
10'd283:y3<=9'd509;
10'd284:y3<=9'd509;
10'd285:y3<=9'd509;
10'd286:y3<=9'd509;
10'd287:y3<=9'd509;
10'd288:y3<=9'd509;
10'd289:y3<=9'd509;
10'd290:y3<=9'd509;
10'd291:y3<=9'd509;
10'd292:y3<=9'd510;
10'd293:y3<=9'd510;
10'd294:y3<=9'd510;
10'd295:y3<=9'd510;
10'd296:y3<=9'd510;
10'd297:y3<=9'd510;
10'd298:y3<=9'd510;
10'd299:y3<=9'd510;
10'd300:y3<=9'd510;
10'd301:y3<=9'd510;
10'd302:y3<=9'd510;
10'd303:y3<=9'd510;
10'd304:y3<=9'd510;
10'd305:y3<=9'd510;
10'd306:y3<=9'd510;
10'd307:y3<=9'd510;
10'd308:y3<=9'd510;
10'd309:y3<=9'd510;
10'd310:y3<=9'd510;
10'd311:y3<=9'd510;
10'd312:y3<=9'd510;
10'd313:y3<=9'd511;
10'd314:y3<=9'd511;
10'd315:y3<=9'd511;
10'd316:y3<=9'd511;
10'd317:y3<=9'd511;
10'd318:y3<=9'd511;
10'd319:y3<=9'd511;
10'd320:y3<=9'd511;
10'd321:y3<=9'd511;
10'd322:y3<=9'd511;
10'd323:y3<=9'd511;
10'd324:y3<=9'd511;
10'd325:y3<=9'd511;
10'd326:y3<=9'd511;
10'd327:y3<=9'd511;
10'd328:y3<=9'd511;
10'd329:y3<=9'd511;
10'd330:y3<=9'd511;
10'd331:y3<=9'd511;
10'd332:y3<=9'd511;
10'd333:y3<=9'd511;
10'd334:y3<=9'd511;
10'd335:y3<=9'd511;
10'd336:y3<=9'd511;
10'd337:y3<=9'd511;
10'd338:y3<=9'd511;
10'd339:y3<=9'd511;
10'd340:y3<=9'd511;
10'd341:y3<=9'd511;
10'd342:y3<=9'd511;
10'd343:y3<=9'd511;
10'd344:y3<=9'd511;
10'd345:y3<=9'd511;
10'd346:y3<=9'd511;
10'd347:y3<=9'd511;
10'd348:y3<=9'd511;
10'd349:y3<=9'd511;
10'd350:y3<=9'd511;
10'd351:y3<=9'd511;
10'd352:y3<=9'd511;
10'd353:y3<=9'd511;
10'd354:y3<=9'd511;
10'd355:y3<=9'd511;
10'd356:y3<=9'd511;
10'd357:y3<=9'd511;
10'd358:y3<=9'd511;
10'd359:y3<=9'd511;
10'd360:y3<=9'd511;
10'd361:y3<=9'd511;
10'd362:y3<=9'd511;
10'd363:y3<=9'd511;
10'd364:y3<=9'd511;
10'd365:y3<=9'd511;
10'd366:y3<=9'd511;
10'd367:y3<=9'd511;
10'd368:y3<=9'd511;
10'd369:y3<=9'd511;
10'd370:y3<=9'd511;
10'd371:y3<=9'd510;
10'd372:y3<=9'd510;
10'd373:y3<=9'd510;
10'd374:y3<=9'd510;
10'd375:y3<=9'd510;
10'd376:y3<=9'd510;
10'd377:y3<=9'd510;
10'd378:y3<=9'd510;
10'd379:y3<=9'd510;
10'd380:y3<=9'd510;
10'd381:y3<=9'd510;
10'd382:y3<=9'd510;
10'd383:y3<=9'd510;
10'd384:y3<=9'd510;
10'd385:y3<=9'd510;
10'd386:y3<=9'd510;
10'd387:y3<=9'd510;
10'd388:y3<=9'd510;
10'd389:y3<=9'd510;
10'd390:y3<=9'd510;
10'd391:y3<=9'd510;
10'd392:y3<=9'd509;
10'd393:y3<=9'd509;
10'd394:y3<=9'd509;
10'd395:y3<=9'd509;
10'd396:y3<=9'd509;
10'd397:y3<=9'd509;
10'd398:y3<=9'd509;
10'd399:y3<=9'd509;
10'd400:y3<=9'd509;
10'd401:y3<=9'd509;
10'd402:y3<=9'd509;
10'd403:y3<=9'd509;
10'd404:y3<=9'd509;
10'd405:y3<=9'd509;
10'd406:y3<=9'd508;
10'd407:y3<=9'd508;
10'd408:y3<=9'd508;
10'd409:y3<=9'd508;
10'd410:y3<=9'd508;
10'd411:y3<=9'd508;
10'd412:y3<=9'd508;
10'd413:y3<=9'd508;
10'd414:y3<=9'd508;
10'd415:y3<=9'd508;
10'd416:y3<=9'd508;
10'd417:y3<=9'd508;
10'd418:y3<=9'd507;
10'd419:y3<=9'd507;
10'd420:y3<=9'd507;
10'd421:y3<=9'd507;
10'd422:y3<=9'd507;
10'd423:y3<=9'd507;
10'd424:y3<=9'd507;
10'd425:y3<=9'd507;
10'd426:y3<=9'd507;
10'd427:y3<=9'd507;
10'd428:y3<=9'd506;
10'd429:y3<=9'd506;
10'd430:y3<=9'd506;
10'd431:y3<=9'd506;
10'd432:y3<=9'd506;
10'd433:y3<=9'd506;
10'd434:y3<=9'd506;
10'd435:y3<=9'd506;
10'd436:y3<=9'd506;
10'd437:y3<=9'd506;
10'd438:y3<=9'd505;
10'd439:y3<=9'd505;
10'd440:y3<=9'd505;
10'd441:y3<=9'd505;
10'd442:y3<=9'd505;
10'd443:y3<=9'd505;
10'd444:y3<=9'd505;
10'd445:y3<=9'd505;
10'd446:y3<=9'd504;
10'd447:y3<=9'd504;
10'd448:y3<=9'd504;
10'd449:y3<=9'd504;
10'd450:y3<=9'd504;
10'd451:y3<=9'd504;
10'd452:y3<=9'd504;
10'd453:y3<=9'd504;
10'd454:y3<=9'd503;
10'd455:y3<=9'd503;
10'd456:y3<=9'd503;
10'd457:y3<=9'd503;
10'd458:y3<=9'd503;
10'd459:y3<=9'd503;
10'd460:y3<=9'd503;
10'd461:y3<=9'd502;
10'd462:y3<=9'd502;
10'd463:y3<=9'd502;
10'd464:y3<=9'd502;
10'd465:y3<=9'd502;
10'd466:y3<=9'd502;
10'd467:y3<=9'd502;
10'd468:y3<=9'd501;
10'd469:y3<=9'd501;
10'd470:y3<=9'd501;
10'd471:y3<=9'd501;
10'd472:y3<=9'd501;
10'd473:y3<=9'd501;
10'd474:y3<=9'd500;
10'd475:y3<=9'd500;
10'd476:y3<=9'd500;
10'd477:y3<=9'd500;
10'd478:y3<=9'd500;
10'd479:y3<=9'd500;
10'd480:y3<=9'd499;
10'd481:y3<=9'd499;
10'd482:y3<=9'd499;
10'd483:y3<=9'd499;
10'd484:y3<=9'd499;
10'd485:y3<=9'd499;
10'd486:y3<=9'd498;
10'd487:y3<=9'd498;
10'd488:y3<=9'd498;
10'd489:y3<=9'd498;
10'd490:y3<=9'd498;
10'd491:y3<=9'd498;
10'd492:y3<=9'd497;
10'd493:y3<=9'd497;
10'd494:y3<=9'd497;
10'd495:y3<=9'd497;
10'd496:y3<=9'd497;
10'd497:y3<=9'd496;
10'd498:y3<=9'd496;
10'd499:y3<=9'd496;
10'd500:y3<=9'd496;
10'd501:y3<=9'd496;
10'd502:y3<=9'd496;
10'd503:y3<=9'd495;
10'd504:y3<=9'd495;
10'd505:y3<=9'd495;
10'd506:y3<=9'd495;
10'd507:y3<=9'd495;
10'd508:y3<=9'd494;
10'd509:y3<=9'd494;
10'd510:y3<=9'd494;
10'd511:y3<=9'd494;
10'd512:y3<=9'd494;
10'd513:y3<=9'd493;
10'd514:y3<=9'd493;
10'd515:y3<=9'd493;
10'd516:y3<=9'd493;
10'd517:y3<=9'd493;
10'd518:y3<=9'd492;
10'd519:y3<=9'd492;
10'd520:y3<=9'd492;
10'd521:y3<=9'd492;
10'd522:y3<=9'd491;
10'd523:y3<=9'd491;
10'd524:y3<=9'd491;
10'd525:y3<=9'd491;
10'd526:y3<=9'd491;
10'd527:y3<=9'd490;
10'd528:y3<=9'd490;
10'd529:y3<=9'd490;
10'd530:y3<=9'd490;
10'd531:y3<=9'd490;
10'd532:y3<=9'd489;
10'd533:y3<=9'd489;
10'd534:y3<=9'd489;
10'd535:y3<=9'd489;
10'd536:y3<=9'd488;
10'd537:y3<=9'd488;
10'd538:y3<=9'd488;
10'd539:y3<=9'd488;
10'd540:y3<=9'd487;
10'd541:y3<=9'd487;
10'd542:y3<=9'd487;
10'd543:y3<=9'd487;
10'd544:y3<=9'd486;
10'd545:y3<=9'd486;
10'd546:y3<=9'd486;
10'd547:y3<=9'd486;
10'd548:y3<=9'd486;
10'd549:y3<=9'd485;
10'd550:y3<=9'd485;
10'd551:y3<=9'd485;
10'd552:y3<=9'd485;
10'd553:y3<=9'd484;
10'd554:y3<=9'd484;
10'd555:y3<=9'd484;
10'd556:y3<=9'd484;
10'd557:y3<=9'd483;
10'd558:y3<=9'd483;
10'd559:y3<=9'd483;
10'd560:y3<=9'd482;
10'd561:y3<=9'd482;
10'd562:y3<=9'd482;
10'd563:y3<=9'd482;
10'd564:y3<=9'd481;
10'd565:y3<=9'd481;
10'd566:y3<=9'd481;
10'd567:y3<=9'd481;
10'd568:y3<=9'd480;
10'd569:y3<=9'd480;
10'd570:y3<=9'd480;
10'd571:y3<=9'd480;
10'd572:y3<=9'd479;
10'd573:y3<=9'd479;
10'd574:y3<=9'd479;
10'd575:y3<=9'd478;
10'd576:y3<=9'd478;
10'd577:y3<=9'd478;
10'd578:y3<=9'd478;
10'd579:y3<=9'd477;
10'd580:y3<=9'd477;
10'd581:y3<=9'd477;
10'd582:y3<=9'd477;
10'd583:y3<=9'd476;
10'd584:y3<=9'd476;
10'd585:y3<=9'd476;
10'd586:y3<=9'd475;
10'd587:y3<=9'd475;
10'd588:y3<=9'd475;
10'd589:y3<=9'd475;
10'd590:y3<=9'd474;
10'd591:y3<=9'd474;
10'd592:y3<=9'd474;
10'd593:y3<=9'd473;
10'd594:y3<=9'd473;
10'd595:y3<=9'd473;
10'd596:y3<=9'd472;
10'd597:y3<=9'd472;
10'd598:y3<=9'd472;
10'd599:y3<=9'd472;
10'd600:y3<=9'd471;
10'd601:y3<=9'd471;
10'd602:y3<=9'd471;
10'd603:y3<=9'd470;
10'd604:y3<=9'd470;
10'd605:y3<=9'd470;
10'd606:y3<=9'd469;
10'd607:y3<=9'd469;
10'd608:y3<=9'd469;
10'd609:y3<=9'd468;
10'd610:y3<=9'd468;
10'd611:y3<=9'd468;
10'd612:y3<=9'd468;
10'd613:y3<=9'd467;
10'd614:y3<=9'd467;
10'd615:y3<=9'd467;
10'd616:y3<=9'd466;
10'd617:y3<=9'd466;
10'd618:y3<=9'd466;
10'd619:y3<=9'd465;
10'd620:y3<=9'd465;
10'd621:y3<=9'd465;
10'd622:y3<=9'd464;
10'd623:y3<=9'd464;
10'd624:y3<=9'd464;
10'd625:y3<=9'd463;
10'd626:y3<=9'd463;
10'd627:y3<=9'd463;
10'd628:y3<=9'd462;
10'd629:y3<=9'd462;
10'd630:y3<=9'd462;
10'd631:y3<=9'd461;
10'd632:y3<=9'd461;
10'd633:y3<=9'd461;
10'd634:y3<=9'd460;
10'd635:y3<=9'd460;
10'd636:y3<=9'd460;
10'd637:y3<=9'd459;
10'd638:y3<=9'd459;
10'd639:y3<=9'd459;
10'd640:y3<=9'd458;
10'd641:y3<=9'd458;
10'd642:y3<=9'd458;
10'd643:y3<=9'd457;
10'd644:y3<=9'd457;
10'd645:y3<=9'd457;
10'd646:y3<=9'd456;
10'd647:y3<=9'd456;
10'd648:y3<=9'd455;
10'd649:y3<=9'd455;
10'd650:y3<=9'd455;
10'd651:y3<=9'd454;
10'd652:y3<=9'd454;
10'd653:y3<=9'd454;
10'd654:y3<=9'd453;
10'd655:y3<=9'd453;
10'd656:y3<=9'd453;
10'd657:y3<=9'd452;
10'd658:y3<=9'd452;
10'd659:y3<=9'd451;
10'd660:y3<=9'd451;
10'd661:y3<=9'd451;
10'd662:y3<=9'd450;
10'd663:y3<=9'd450;
10'd664:y3<=9'd450;
10'd665:y3<=9'd449;
10'd666:y3<=9'd449;
10'd667:y3<=9'd448;
10'd668:y3<=9'd448;
10'd669:y3<=9'd448;
10'd670:y3<=9'd447;
10'd671:y3<=9'd447;
10'd672:y3<=9'd447;
10'd673:y3<=9'd446;
10'd674:y3<=9'd446;
10'd675:y3<=9'd445;
10'd676:y3<=9'd445;
10'd677:y3<=9'd445;
10'd678:y3<=9'd444;
10'd679:y3<=9'd444;
10'd680:y3<=9'd444;
10'd681:y3<=9'd443;
10'd682:y3<=9'd443;
10'd683:y3<=9'd442;
10'd684:y3<=9'd441;
10'd685:y3<=9'd440;
10'd686:y3<=9'd439;
10'd687:y3<=9'd437;
10'd688:y3<=9'd436;
10'd689:y3<=9'd435;
10'd690:y3<=9'd434;
10'd691:y3<=9'd433;
10'd692:y3<=9'd431;
10'd693:y3<=9'd430;
10'd694:y3<=9'd429;
10'd695:y3<=9'd428;
10'd696:y3<=9'd427;
10'd697:y3<=9'd425;
10'd698:y3<=9'd424;
10'd699:y3<=9'd423;
10'd700:y3<=9'd422;
10'd701:y3<=9'd421;
10'd702:y3<=9'd420;
10'd703:y3<=9'd418;
10'd704:y3<=9'd417;
10'd705:y3<=9'd416;
10'd706:y3<=9'd415;
10'd707:y3<=9'd414;
10'd708:y3<=9'd412;
10'd709:y3<=9'd411;
10'd710:y3<=9'd410;
10'd711:y3<=9'd409;
10'd712:y3<=9'd408;
10'd713:y3<=9'd406;
10'd714:y3<=9'd405;
10'd715:y3<=9'd404;
10'd716:y3<=9'd403;
10'd717:y3<=9'd401;
10'd718:y3<=9'd400;
10'd719:y3<=9'd399;
10'd720:y3<=9'd398;
10'd721:y3<=9'd397;
10'd722:y3<=9'd395;
10'd723:y3<=9'd394;
10'd724:y3<=9'd393;
10'd725:y3<=9'd392;
10'd726:y3<=9'd391;
10'd727:y3<=9'd389;
10'd728:y3<=9'd388;
10'd729:y3<=9'd387;
10'd730:y3<=9'd386;
10'd731:y3<=9'd384;
10'd732:y3<=9'd383;
10'd733:y3<=9'd382;
10'd734:y3<=9'd381;
10'd735:y3<=9'd380;
10'd736:y3<=9'd378;
10'd737:y3<=9'd377;
10'd738:y3<=9'd376;
10'd739:y3<=9'd375;
10'd740:y3<=9'd373;
10'd741:y3<=9'd372;
10'd742:y3<=9'd371;
10'd743:y3<=9'd370;
10'd744:y3<=9'd368;
10'd745:y3<=9'd367;
10'd746:y3<=9'd366;
10'd747:y3<=9'd365;
10'd748:y3<=9'd363;
10'd749:y3<=9'd362;
10'd750:y3<=9'd361;
10'd751:y3<=9'd360;
10'd752:y3<=9'd359;
10'd753:y3<=9'd357;
10'd754:y3<=9'd356;
10'd755:y3<=9'd355;
10'd756:y3<=9'd354;
10'd757:y3<=9'd352;
10'd758:y3<=9'd351;
10'd759:y3<=9'd350;
10'd760:y3<=9'd349;
10'd761:y3<=9'd347;
10'd762:y3<=9'd346;
10'd763:y3<=9'd345;
10'd764:y3<=9'd344;
10'd765:y3<=9'd342;
10'd766:y3<=9'd341;
10'd767:y3<=9'd340;
10'd768:y3<=9'd339;
10'd769:y3<=9'd337;
10'd770:y3<=9'd336;
10'd771:y3<=9'd335;
10'd772:y3<=9'd334;
10'd773:y3<=9'd332;
10'd774:y3<=9'd331;
10'd775:y3<=9'd330;
10'd776:y3<=9'd328;
10'd777:y3<=9'd327;
10'd778:y3<=9'd326;
10'd779:y3<=9'd325;
10'd780:y3<=9'd323;
10'd781:y3<=9'd322;
10'd782:y3<=9'd321;
10'd783:y3<=9'd320;
10'd784:y3<=9'd318;
10'd785:y3<=9'd317;
10'd786:y3<=9'd316;
10'd787:y3<=9'd315;
10'd788:y3<=9'd313;
10'd789:y3<=9'd312;
10'd790:y3<=9'd311;
10'd791:y3<=9'd309;
10'd792:y3<=9'd308;
10'd793:y3<=9'd307;
10'd794:y3<=9'd306;
10'd795:y3<=9'd304;
10'd796:y3<=9'd303;
10'd797:y3<=9'd302;
10'd798:y3<=9'd301;
10'd799:y3<=9'd299;
10'd800:y3<=9'd298;
10'd801:y3<=9'd297;
10'd802:y3<=9'd295;
10'd803:y3<=9'd294;
10'd804:y3<=9'd293;
10'd805:y3<=9'd292;
10'd806:y3<=9'd290;
10'd807:y3<=9'd289;
10'd808:y3<=9'd288;
10'd809:y3<=9'd286;
10'd810:y3<=9'd285;
10'd811:y3<=9'd284;
10'd812:y3<=9'd283;
10'd813:y3<=9'd281;
10'd814:y3<=9'd280;
10'd815:y3<=9'd279;
10'd816:y3<=9'd277;
10'd817:y3<=9'd276;
10'd818:y3<=9'd275;
10'd819:y3<=9'd274;
10'd820:y3<=9'd272;
10'd821:y3<=9'd271;
10'd822:y3<=9'd270;
10'd823:y3<=9'd268;
10'd824:y3<=9'd267;
10'd825:y3<=9'd266;
10'd826:y3<=9'd264;
10'd827:y3<=9'd263;
10'd828:y3<=9'd262;
10'd829:y3<=9'd261;
10'd830:y3<=9'd259;
10'd831:y3<=9'd258;
10'd832:y3<=9'd257;
10'd833:y3<=9'd255;
10'd834:y3<=9'd254;
10'd835:y3<=9'd253;
10'd836:y3<=9'd251;
10'd837:y3<=9'd250;
10'd838:y3<=9'd249;
10'd839:y3<=9'd248;
10'd840:y3<=9'd246;
10'd841:y3<=9'd245;
10'd842:y3<=9'd244;
10'd843:y3<=9'd242;
10'd844:y3<=9'd241;
10'd845:y3<=9'd240;
10'd846:y3<=9'd238;
10'd847:y3<=9'd237;
10'd848:y3<=9'd236;
10'd849:y3<=9'd234;
10'd850:y3<=9'd233;
10'd851:y3<=9'd232;
10'd852:y3<=9'd231;
10'd853:y3<=9'd229;
10'd854:y3<=9'd228;
10'd855:y3<=9'd227;
10'd856:y3<=9'd225;
10'd857:y3<=9'd224;
10'd858:y3<=9'd223;
10'd859:y3<=9'd221;
10'd860:y3<=9'd220;
10'd861:y3<=9'd219;
10'd862:y3<=9'd217;
10'd863:y3<=9'd216;
10'd864:y3<=9'd215;
10'd865:y3<=9'd213;
10'd866:y3<=9'd212;
10'd867:y3<=9'd211;
10'd868:y3<=9'd209;
10'd869:y3<=9'd208;
10'd870:y3<=9'd207;
10'd871:y3<=9'd206;
10'd872:y3<=9'd204;
10'd873:y3<=9'd203;
10'd874:y3<=9'd202;
10'd875:y3<=9'd200;
10'd876:y3<=9'd199;
10'd877:y3<=9'd198;
10'd878:y3<=9'd196;
10'd879:y3<=9'd195;
10'd880:y3<=9'd194;
10'd881:y3<=9'd192;
10'd882:y3<=9'd191;
10'd883:y3<=9'd190;
10'd884:y3<=9'd188;
10'd885:y3<=9'd187;
10'd886:y3<=9'd186;
10'd887:y3<=9'd184;
10'd888:y3<=9'd183;
10'd889:y3<=9'd182;
10'd890:y3<=9'd180;
10'd891:y3<=9'd179;
10'd892:y3<=9'd178;
10'd893:y3<=9'd176;
10'd894:y3<=9'd175;
10'd895:y3<=9'd174;
10'd896:y3<=9'd172;
10'd897:y3<=9'd171;
10'd898:y3<=9'd170;
10'd899:y3<=9'd168;
10'd900:y3<=9'd167;
10'd901:y3<=9'd166;
10'd902:y3<=9'd164;
10'd903:y3<=9'd163;
10'd904:y3<=9'd162;
10'd905:y3<=9'd160;
10'd906:y3<=9'd159;
10'd907:y3<=9'd158;
10'd908:y3<=9'd156;
10'd909:y3<=9'd155;
10'd910:y3<=9'd154;
10'd911:y3<=9'd152;
10'd912:y3<=9'd151;
10'd913:y3<=9'd150;
10'd914:y3<=9'd148;
10'd915:y3<=9'd147;
10'd916:y3<=9'd146;
10'd917:y3<=9'd144;
10'd918:y3<=9'd143;
10'd919:y3<=9'd142;
10'd920:y3<=9'd140;
10'd921:y3<=9'd139;
10'd922:y3<=9'd138;
10'd923:y3<=9'd136;
10'd924:y3<=9'd135;
10'd925:y3<=9'd134;
10'd926:y3<=9'd132;
10'd927:y3<=9'd131;
10'd928:y3<=9'd129;
10'd929:y3<=9'd128;
10'd930:y3<=9'd127;
10'd931:y3<=9'd125;
10'd932:y3<=9'd124;
10'd933:y3<=9'd123;
10'd934:y3<=9'd121;
10'd935:y3<=9'd120;
10'd936:y3<=9'd119;
10'd937:y3<=9'd117;
10'd938:y3<=9'd116;
10'd939:y3<=9'd115;
10'd940:y3<=9'd113;
10'd941:y3<=9'd112;
10'd942:y3<=9'd111;
10'd943:y3<=9'd109;
10'd944:y3<=9'd108;
10'd945:y3<=9'd107;
10'd946:y3<=9'd105;
10'd947:y3<=9'd104;
10'd948:y3<=9'd103;
10'd949:y3<=9'd101;
10'd950:y3<=9'd100;
10'd951:y3<=9'd99;
10'd952:y3<=9'd97;
10'd953:y3<=9'd96;
10'd954:y3<=9'd94;
10'd955:y3<=9'd93;
10'd956:y3<=9'd92;
10'd957:y3<=9'd90;
10'd958:y3<=9'd89;
10'd959:y3<=9'd88;
10'd960:y3<=9'd86;
10'd961:y3<=9'd85;
10'd962:y3<=9'd84;
10'd963:y3<=9'd82;
10'd964:y3<=9'd81;
10'd965:y3<=9'd80;
10'd966:y3<=9'd78;
10'd967:y3<=9'd77;
10'd968:y3<=9'd76;
10'd969:y3<=9'd74;
10'd970:y3<=9'd73;
10'd971:y3<=9'd71;
10'd972:y3<=9'd70;
10'd973:y3<=9'd69;
10'd974:y3<=9'd67;
10'd975:y3<=9'd66;
10'd976:y3<=9'd65;
10'd977:y3<=9'd63;
10'd978:y3<=9'd62;
10'd979:y3<=9'd61;
10'd980:y3<=9'd59;
10'd981:y3<=9'd58;
10'd982:y3<=9'd57;
10'd983:y3<=9'd55;
10'd984:y3<=9'd54;
10'd985:y3<=9'd52;
10'd986:y3<=9'd51;
10'd987:y3<=9'd50;
10'd988:y3<=9'd48;
10'd989:y3<=9'd47;
10'd990:y3<=9'd46;
10'd991:y3<=9'd44;
10'd992:y3<=9'd43;
10'd993:y3<=9'd42;
10'd994:y3<=9'd40;
10'd995:y3<=9'd39;
10'd996:y3<=9'd38;
10'd997:y3<=9'd36;
10'd998:y3<=9'd35;
10'd999:y3<=9'd33;
10'd1000:y3<=9'd32;
10'd1001:y3<=9'd31;
10'd1002:y3<=9'd29;
10'd1003:y3<=9'd28;
10'd1004:y3<=9'd27;
10'd1005:y3<=9'd25;
10'd1006:y3<=9'd24;
10'd1007:y3<=9'd23;
10'd1008:y3<=9'd21;
10'd1009:y3<=9'd20;
10'd1010:y3<=9'd19;
10'd1011:y3<=9'd17;
10'd1012:y3<=9'd16;
10'd1013:y3<=9'd14;
10'd1014:y3<=9'd13;
10'd1015:y3<=9'd12;
10'd1016:y3<=9'd10;
10'd1017:y3<=9'd9;
10'd1018:y3<=9'd8;
10'd1019:y3<=9'd6;
10'd1020:y3<=9'd5;
10'd1021:y3<=9'd4;
10'd1022:y3<=9'd2;
10'd1023:y3<=9'd1;
endcase

endmodule