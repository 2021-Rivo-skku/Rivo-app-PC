package UDP_Demo;


import com.sun.jdi.event.ExceptionEvent;
import jdk.jfr.Unsigned;

import javax.swing.*;
import javax.swing.plaf.basic.BasicSeparatorUI;
import javax.swing.text.AbstractDocument;
import java.beans.beancontext.BeanContext;
import java.io.*;
import java.lang.reflect.Array;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.util.*;

public class Client {
    static short MAX_BUFFER_SIZE = 128;


    public static int byteToShort(byte[] bytes) {

        int newValue = 0;
        newValue |= (((int) bytes[0]) << 8) & 0xFF00;
        newValue |= (((int) bytes[1])) & 0xFF;

        return newValue;
    }

    public static short crc16_compute(byte[] data){
        short crc = (short) 0xffff;
        for(int i=0; i<data.length; i++) {
            crc = (short)((crc >>> 8) & 0xff | (crc << 8));
            crc ^= data[i] & 0xff;
            crc ^= (crc & 0xff) >>> 4;
            crc ^= (crc << 8) << 4;
            crc ^= ((crc & 0xff) << 4) << 1;
        }
        return crc;
    }

    public static void crc16_check(byte[] data){             //data == bufferToReceive
        //length 뽑아서 6 + length 한 곳 부터 2byte 읽고 실제 값이랑 비교
        if(data[7] == (byte) 0x87){
            System.out.println("CRC Error!!!");
            return;
        }
        short bufferlen = (short) byteToShort(new byte[]{data[5], data[4]});
        byte[] realData = Arrays.copyOfRange(data, 6, bufferlen + 6);         //crc 뺀 data로 계산해야 함
        short crc = crc16_compute(realData);
        bufferlen += 6;                 //STX, ID, length 6byte 더해줘야 실제 crc 시작 인덱스
        short realCrc = 0;
        realCrc |= (short) (data[bufferlen++]) & 0xFF;          //패킷으로 담겨 넘어온 crc 추출
        realCrc |= (short) (data[bufferlen++] << 8) & 0xFF00;

        System.out.println("received crc: " + realCrc);
        System.out.println("computed crc: " + crc);

        

        if(crc == realCrc){
            System.out.println("CRC Checking == TRUE");
        }else{
            System.out.println("CRC Checking == FALSE");
        }
    }

    public static byte[] getRequest(char id_1, char id_2) throws IOException {

        byte[] bufferToSend = new byte[1000];
        int bufferlen;

        bufferToSend[0] = 'A';
        bufferToSend[1] = 'T';
        bufferToSend[2] = (byte) id_1;
        bufferToSend[3] = (byte) id_2;
        bufferToSend[6] = 0x0;

        bufferlen = 1;

        bufferToSend[4] = (byte) (bufferlen & 0xFF);
        bufferToSend[5] = (byte) ((bufferlen >> 8 )& 0xFF);

        int offset = bufferlen + 6;
        short crc = crc16_compute(Arrays.copyOfRange(bufferToSend, 6, bufferlen + 6));
        bufferToSend[offset++] = (byte) (crc & 0xFF);
        bufferToSend[offset++] = (byte) ((crc >> 8)& 0xFF);

        bufferToSend[offset++] = 0x0D;
        bufferToSend[offset++] = 0x0A;

        return bufferToSend;

    }

    public static byte[] setRequest(byte[] bufferToSend, char id_1, char id_2, int bufferlen){
        bufferToSend[0] = 'A';
        bufferToSend[1] = 'T';
        bufferToSend[2] = (byte) id_1;
        bufferToSend[3] = (byte) id_2;
        bufferToSend[6] = 0x1;

        bufferToSend[4] = (byte) (bufferlen & 0xFF);
        bufferToSend[5] = (byte) ((bufferlen >> 8 )& 0xFF);

        int offset = bufferlen + 6;
        short crc = crc16_compute(Arrays.copyOfRange(bufferToSend, 6, bufferlen + 6));
        bufferToSend[offset++] = (byte) (crc & 0xFF);
        bufferToSend[offset++] = (byte) ((crc >> 8)& 0xFF);

        bufferToSend[offset++] = 0x0D;
        bufferToSend[offset++] = 0x0A;

        return bufferToSend;
    }



    public static void main(String[] args) throws IOException, InterruptedException {
        BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
        DatagramSocket ds = new DatagramSocket();

        InetAddress ia = InetAddress.getByName("127.0.0.1");

        System.out.println("Select Mode(1. Check    2. Modify)");
        int mode;
        Scanner sc = new Scanner(System.in);
        mode = sc.nextInt();
        sc.nextLine();              //앞에서 생긴 개행문자 버려서 뒤의 nextline 스킵되는거 방지.





/*


        if(mode == 1){              //설정값 조회 - 요청 보내고, 답변 받고, 출력
            byte[] bufferToSend = new byte[1000];           //보낼 정보 저장하는 버퍼
            bufferToSend[0] = 'A';
            bufferToSend[1] = 'T';
            bufferToSend[2] = 'L';
            bufferToSend[3] = 'N';

            byte[] bufferToReceive = new byte[1000];        //값 받아올 버퍼

            short bufferlen = 1;
            bufferToSend[6] = (byte)0x0;      //STX, ID, length 크기 제외하고 7부터 payload 시작

            bufferToSend[4] = (byte) (bufferlen & 0xFF);    //4, 5 index에 length 정보 세팅
            bufferToSend[5] = (byte) ((bufferlen >> 8 )& 0xFF);

            System.out.println(bufferToSend[4] + " " + bufferToSend[5]);


            DatagramPacket dpSend = new DatagramPacket(bufferToSend, bufferToSend.length, ia, 6999);
            ds.send(dpSend);


            DatagramPacket dpReceive = new DatagramPacket(bufferToReceive, bufferToReceive.length);
            ds.receive(dpReceive);

            String rivoInfo = new String(bufferToReceive, 7, byteToShort(new byte[]{bufferToReceive[5], bufferToReceive[4]}));
            System.out.println("rivoInfo : " + rivoInfo);

        }
        else if(mode == 2){         //설정값 변경 - 요청 보내고, 변경된 값으로 답변 받고, 출력
            byte[] bufferToSend = new byte[1000];           //보낼 정보 저장하는 버퍼
            bufferToSend[0] = 'A';
            bufferToSend[1] = 'T';
            bufferToSend[2] = 'L';
            bufferToSend[3] = 'N';
            bufferToSend[6] = (byte)0x1;      //STX, ID, length 크기 제외하고 7부터 payload 시작

            byte[] bufferToReceive = new byte[1000];        //값 받아올 버퍼
            short bufferlen;
            String newRivoInfo;
            System.out.print("Enter new rivoInfo: ");
            newRivoInfo = sc.nextLine();                         //수정할 값 입력받음

            bufferlen = (short) (newRivoInfo.length() + 1);

            bufferToSend[4] = (byte) (bufferlen & 0xFF);    //4, 5 index에 length 정보 세팅 (short to byte array)
            bufferToSend[5] = (byte) ((bufferlen >> 8 )& 0xFF);

            System.out.println("bufferlen: " + bufferlen);

            System.arraycopy(newRivoInfo.getBytes(), 0, bufferToSend, 7, bufferlen - 1);

            int offset = bufferlen + 6;             //bufferlen + 6 == STX, ID, length, payload 까지 포함한 크기
            short crc = crc16_compute(Arrays.copyOfRange(bufferToSend, 6, bufferlen + 6));        //CRC Setting (payload만 사용)
            System.out.println("computed crc: " + crc);
            bufferToSend[offset++] = (byte) (crc & 0xFF);
            bufferToSend[offset++] = (byte) ((crc >> 8)& 0xFF);

            DatagramPacket dpSend = new DatagramPacket(bufferToSend, bufferToSend.length, ia, 6999);
            ds.send(dpSend);            //요청 패킷 전송

            DatagramPacket dpReceive = new DatagramPacket(bufferToReceive, bufferToReceive.length);
            ds.receive(dpReceive);

            crc16_check(bufferToReceive);

            //변경된 설정값 Server로부터 다시 받아서 저장
            System.out.println(bufferToReceive[4] + " " + bufferToReceive[5]);        //[4] = 5, [5] = 0
            String rivoInfo = new String(bufferToReceive, 7, byteToShort(new byte[]{bufferToReceive[5], bufferToReceive[4]}));
            System.out.println("rivoInfo has been successfully changed to [" + rivoInfo + "]");

        }*/


        if(mode == 210){            //Version GET
            byte[] bufferToSend;
            byte[] bufferToReceive = new byte[1000];
            bufferToSend = getRequest('F', 'V');
            DatagramPacket dpSend = new DatagramPacket(bufferToSend, bufferToSend.length, ia, 6999);
            ds.send(dpSend);

            DatagramPacket dpReceive = new DatagramPacket(bufferToReceive, bufferToReceive.length);
            ds.receive(dpReceive);
            crc16_check(bufferToReceive);

            int recvBufferlen = byteToShort(new byte[]{bufferToReceive[5], bufferToReceive[4]});
            String firmVer = new String(bufferToReceive, 8, recvBufferlen - 2);
            System.out.println("Firmware Version " + firmVer);
        }
        
        else if(mode == 221){           //Date/Time SET

        }
        else if(mode == 230){           //Language GET
            byte[] bufferToSend;
            byte[] bufferToReceive = new byte[1000];
            bufferToSend = getRequest('L', 'N');
            DatagramPacket dpSend = new DatagramPacket(bufferToSend, bufferToSend.length, ia, 6999);
            ds.send(dpSend);

            DatagramPacket dpReceive = new DatagramPacket(bufferToReceive, bufferToReceive.length);
            ds.receive(dpReceive);
            crc16_check(bufferToReceive);

            int recvBufferlen = byteToShort(new byte[]{bufferToReceive[5], bufferToReceive[4]});
            String language = new String(bufferToReceive, 8, recvBufferlen - 2);
            System.out.println("Language Info: " + language);
        }
        else  if(mode == 231){          //Language SET
            byte[] bufferToSend = new byte[1000];
            byte[] bufferToReceive = new byte[1000];
            String language;
            int bufferlen;
            System.out.print("Enter new Language Setting : ");
            language = sc.nextLine();

            bufferlen = (short) (language.length() + 1);

            System.arraycopy(language.getBytes(), 0, bufferToSend, 7, bufferlen - 1);
            bufferToSend = setRequest(bufferToSend, 'L', 'N', bufferlen);

            System.out.println(new String(bufferToSend, 7, bufferlen - 1));

            DatagramPacket dpSend = new DatagramPacket(bufferToSend, bufferToSend.length, ia, 6999);
            ds.send(dpSend);
            DatagramPacket dpReceive = new DatagramPacket(bufferToReceive, bufferToReceive.length);
            ds.receive(dpReceive);

            crc16_check(bufferToReceive);
            if(bufferToReceive[7] == 0x00){
                System.out.println("Language Setting has been successfully changed to [" + language + "]");
            }
        }
        else if(mode == 240){           //Screen Reader GET
            byte[] bufferToSend;
            byte[] bufferToReceive = new byte[1000];
            bufferToSend = getRequest('S', 'R');
            DatagramPacket dpSend = new DatagramPacket(bufferToSend, bufferToSend.length, ia, 6999);
            ds.send(dpSend);

            DatagramPacket dpReceive = new DatagramPacket(bufferToReceive, bufferToReceive.length);
            ds.receive(dpReceive);
            crc16_check(bufferToReceive);

            int recvBufferlen = byteToShort(new byte[]{bufferToReceive[5], bufferToReceive[4]});
            String screenReader = new String(bufferToReceive, 8, recvBufferlen - 2);
            System.out.println("Screen reader Info: " + screenReader);
        }
        else if(mode == 250){           //Voice Guidance GET
            byte[] bufferToSend;
            byte[] bufferToReceive = new byte[1000];
            bufferToSend = getRequest('V', 'G');
            DatagramPacket dpSend = new DatagramPacket(bufferToSend, bufferToSend.length, ia, 6999);
            ds.send(dpSend);

            DatagramPacket dpReceive = new DatagramPacket(bufferToReceive, bufferToReceive.length);
            ds.receive(dpReceive);
            crc16_check(bufferToReceive);

            int recvBufferlen = byteToShort(new byte[]{bufferToReceive[5], bufferToReceive[4]});
            byte voiceGuidance = bufferToReceive[8];
            System.out.println("Voice Guidance Info:  "  + voiceGuidance);
        }
        else if(mode == 290){           //Device Info GET
            byte[] bufferToSend;
            byte[] bufferToReceive = new byte[1000];
            bufferToSend = getRequest('I', 'F');
            DatagramPacket dpSend = new DatagramPacket(bufferToSend, bufferToSend.length, ia, 6999);
            ds.send(dpSend);

            DatagramPacket dpReceive = new DatagramPacket(bufferToReceive, bufferToReceive.length);
            ds.receive(dpReceive);
            crc16_check(bufferToReceive);

            int recvBufferlen = byteToShort(new byte[]{bufferToReceive[5], bufferToReceive[4]});
            String rivoInfo = new String(bufferToReceive, 8, recvBufferlen - 2);
            System.out.println("Device Info:  " + rivoInfo);
        }
        else if(mode == 2100){          //Find My Rivo
            byte[] bufferToSend;
            byte[] bufferToReceive = new byte[1000];
            bufferToSend = getRequest('R', 'V');
            DatagramPacket dpSend = new DatagramPacket(bufferToSend, bufferToSend.length, ia, 6999);
            ds.send(dpSend);

            DatagramPacket dpReceive = new DatagramPacket(bufferToReceive, bufferToReceive.length);
            ds.receive(dpReceive);
            crc16_check(bufferToReceive);
        }
        else if(mode == 2110){          //MTU Size GET
            byte[] bufferToSend;
            byte[] bufferToReceive = new byte[1000];
            bufferToSend = getRequest('M', 'T');
            DatagramPacket dpSend = new DatagramPacket(bufferToSend, bufferToSend.length, ia, 6999);
            ds.send(dpSend);

            DatagramPacket dpReceive = new DatagramPacket(bufferToReceive, bufferToReceive.length);
            ds.receive(dpReceive);
            crc16_check(bufferToReceive);

            int recvBufferlen = byteToShort(new byte[]{bufferToReceive[5], bufferToReceive[4]});
            short MTU_Size = (short) byteToShort(new byte[]{bufferToReceive[9], bufferToReceive[8]});
            System.out.println("Device Info:  " + MTU_Size);
        }
        else if(mode == 500){           //File Send
            byte[] bufferToSend = new byte[1000];
            byte[] bufferToReceive = new byte[100];
            short data_info_size;           //filename, firmware version . . .
            int data_total_size;
            String data_info;
            int bufferlen;

            bufferToSend[0] = 'A';
            bufferToSend[1] = 'T';
            bufferToSend[2] = 'U';
            bufferToSend[3] = 'M';
            bufferToSend[6] = 0x00;         //opcode = START
            bufferToSend[7] = 0x00;         //data_type = locale
                                            //8~11 : data_total_size
                                            //12~15 : total_crc

            System.out.print("Enter File Name: ");
            data_info = sc.nextLine();              //data_info: file name
            File fileToSend = new File("./" + data_info);
            if(!fileToSend.exists()){           //File Not exist
                System.out.println("File Not Exist");
            }

            data_info_size = (short) data_info.length();
            data_total_size = (int) fileToSend.length();

            bufferToSend[8] = (byte) (data_total_size & 0xff);          //data_total_size (little endian)
            bufferToSend[9] = (byte) ((data_total_size >> 8) & 0xff);
            bufferToSend[10] = (byte) ((data_total_size >> 16) & 0xff);
            bufferToSend[11] = (byte) ((data_total_size >> 24) & 0xff);

            bufferToSend[12] = 0x1;         //total crc (little endian)
            bufferToSend[13] = 0x1;
            bufferToSend[14] = 0x1;
            bufferToSend[15] = 0x1;

            bufferToSend[16] = (byte) (data_info_size & 0xff);          //data_info_size
            bufferToSend[17] = (byte) ((data_info_size >> 8) & 0xff);

            System.arraycopy(data_info.getBytes(), 0, bufferToSend, 18, data_info_size);
            bufferlen = data_info_size + 12;
            bufferToSend[4] = (byte) (bufferlen & 0xff);            //length
            bufferToSend[5] = (byte) ((bufferlen >> 8) & 0xff);

            int offset = bufferlen + 6;
            short crc = crc16_compute(Arrays.copyOfRange(bufferToSend, 6, bufferlen + 6));
            bufferToSend[offset++] = (byte) (crc & 0xff);
            bufferToSend[offset++] = (byte) ((crc >> 8) & 0xff);
            bufferToSend[offset++] = (byte) 0x0D;
            bufferToSend[offset++] = (byte) 0x0A;

            DatagramPacket dpSend = new DatagramPacket(bufferToSend, offset, ia, 6999);
            ds.send(dpSend);        //START Request
            DatagramPacket dpReceive = new DatagramPacket(bufferToReceive, bufferToReceive.length);
            ds.receive(dpReceive);
            System.out.println("File Transfer Start!");

            Arrays.fill(bufferToSend, (byte) 0x0);
            Arrays.fill(bufferToReceive, (byte) 0x0);

            short seq_num = 1;

            /*

            byte[] buffer = new byte[data_total_size];
            FileInputStream fis = new FileInputStream(data_info);
            fis.read(buffer, 0, data_total_size);

            bufferToSend[0] = 'A';
            bufferToSend[1] = 'T';
            bufferToSend[2] = 'U';
            bufferToSend[3] = 'M';
            bufferToSend[6] = (byte) 0x1;

            bufferToSend[7] = (byte) (seq_num & 0xff);
            bufferToSend[8] = (byte) ((seq_num >> 8) & 0xff);
            bufferToSend[11] = (byte) (data_total_size & 0xff);
            bufferToSend[12] = (byte) ((data_total_size >> 8) & 0xff);
            bufferlen = data_total_size + 7;
            bufferToSend[4] = (byte) (bufferlen & 0xff);
            bufferToSend[5] = (byte) ((bufferlen >> 8) & 0xff);

            offset = 13 + data_total_size;
            short data_crc = crc16_compute(Arrays.copyOfRange(bufferToSend, 6, offset));
            bufferToSend[offset++] = (byte) (data_crc & 0xff);
            bufferToSend[offset++] = (byte) ((data_crc >> 8) & 0xff);
            bufferToSend[offset++] = 0x0D;
            bufferToSend[offset++] = 0x0A;

            dpSend = new DatagramPacket(bufferToSend, offset, ia, 6999);
            ds.send(dpSend);
            dpReceive = new DatagramPacket(bufferToReceive, bufferToReceive.length);
            ds.receive(dpReceive);

             */
            FileInputStream fis = new FileInputStream(data_info);

            int totalRead = 0;
            while(true){
                if(totalRead >= data_total_size) break;
                bufferToSend[0] = 'A';
                bufferToSend[1] = 'T';
                bufferToSend[2] = 'U';
                bufferToSend[3] = 'M';
                bufferToSend[6] = (byte) 0x1;

                bufferToSend[7] = (byte) (seq_num & 0xff);
                bufferToSend[8] = (byte) ((seq_num >> 8) & 0xff);
                //9~10: crc

                byte[] buffer = new byte[MAX_BUFFER_SIZE];
                int readBytes;
                readBytes = fis.read(buffer, 0, MAX_BUFFER_SIZE);
                totalRead += readBytes;

                short data_size = (short) readBytes;
                bufferToSend[11] = (byte) (data_size & 0xff);
                bufferToSend[12] = (byte) ((data_size >> 8) & 0xff);

                bufferlen = readBytes + 7;
                System.out.println("bufferlen: " + bufferlen);
                bufferToSend[4] = (byte) (bufferlen & 0xff);
                bufferToSend[5] = (byte) ((bufferlen >> 8) & 0xff);

                System.arraycopy(buffer, 0, bufferToSend, 13, data_size);

                offset = 13 + data_size;

                short data_crc = crc16_compute(Arrays.copyOfRange(bufferToSend, 6, offset));
                bufferToSend[offset++] = (byte) (data_crc & 0xff);
                bufferToSend[offset++] = (byte) ((data_crc >> 8) & 0xff);
                bufferToSend[offset++] = 0x0D;
                bufferToSend[offset++] = 0x0A;

                dpSend = new DatagramPacket(bufferToSend, offset, ia, 6999);
                ds.send(dpSend);
                System.out.println(seq_num);
                seq_num++;

                dpReceive = new DatagramPacket(bufferToReceive, bufferToReceive.length);
                ds.receive(dpReceive);
            }

            Arrays.fill(bufferToSend, (byte) 0x0);
            Arrays.fill(bufferToReceive, (byte) 0x0);

            bufferToSend[0] = 'A';
            bufferToSend[1] = 'T';
            bufferToSend[2] = 'U';
            bufferToSend[3] = 'M';
            bufferlen = 5;
            bufferToSend[4] = (byte) (bufferlen & 0xff);
            bufferToSend[5] = (byte) ((bufferlen >> 8) & 0xff);
            bufferToSend[6] = (byte) 0x2;       //VERIFY
            bufferToSend[7] = (byte) (data_total_size & 0xff);          //data_total_size (little endian)
            bufferToSend[8] = (byte) ((data_total_size >> 8) & 0xff);
            bufferToSend[9] = (byte) ((data_total_size >> 16) & 0xff);
            bufferToSend[10] = (byte) ((data_total_size >> 24) & 0xff);

            crc = crc16_compute(Arrays.copyOfRange(bufferToSend, 6, 11));
            bufferToSend[11] = (byte) (crc & 0xff);
            bufferToSend[12] = (byte) ((crc >> 8) & 0xff);
            bufferToSend[13] = 0x0D;
            bufferToSend[14]= 0x0A;

            dpSend = new DatagramPacket(bufferToSend, bufferlen + 10, ia, 6999);
            ds.send(dpSend);
            dpReceive = new DatagramPacket(bufferToReceive, bufferToReceive.length);
            ds.receive(dpReceive);
            System.out.println("Verifying. . .");

            Arrays.fill(bufferToSend, (byte) 0x0);
            Arrays.fill(bufferToReceive, (byte) 0x0);



            bufferToSend[0] = 'A';
            bufferToSend[1] = 'T';
            bufferToSend[2] = 'U';
            bufferToSend[3] = 'M';
            bufferlen = 2;
            bufferToSend[4] = (byte) (bufferlen & 0xff);
            bufferToSend[5] = (byte) ((bufferlen >> 8) & 0xff);
            bufferToSend[6] = 0x3;          //END
            bufferToSend[7] = 0x1;           //Action ??

            crc = crc16_compute(Arrays.copyOfRange(bufferToSend, 6, bufferlen + 6));
            bufferToSend[8] = (byte) (crc & 0xff);
            bufferToSend[9] = (byte) ((crc >> 8) & 0xff);
            bufferToSend[10] = 0x0D;
            bufferToSend[11] = 0x0A;

            dpSend = new DatagramPacket(bufferToSend, bufferlen + 10, ia, 6999);
            ds.send(dpSend);

            dpReceive = new DatagramPacket(bufferToReceive, bufferToReceive.length);
            ds.receive(dpReceive);
            System.out.println("File Transfer Complete!");




        }


    }
}



