%% Texas Hospitalization & Death: Scatterplots

% Hospitalization Data from DSHS
DailyHOSPTX = [827
1132
1153
1252
1491
1439
1532
1514
1338
1176
1409
1538
1459
1522
1321
1471
1411
1419
1678
1649
1674
1597
1542
1563
1682
1702
1686
1778
1725
1540
1533
1888
1812
1750
1734
1735
1626
1525
1725
1676
1648
1716
1791
1512
1551
1732
1791
1680
1578
1688
1572
1511
1534
1645
1692
1701
1752
1684
1756
1773
1799
1796
1855
1822
1878
1935
2056
2153
2008
2166
2242
2287
2326
2518
2793
2947
3148
3247
3409
3711
4092
4389
4739
5102
5523
5497
5913
6533
6904
7382
7652
7890
8181
8698
9286
9610
9689
10002
10083
10410
10405
10569
10471
10457
10632
10658
10592
10569
10848
10893
8858
10036
9827
10075
9781
9593]';

% Death from Covid Tracking Project

deathIncrease = [164
675
153
168
196
173
197
131
62
93
130
174
129
110
87
43
80
99
95
105
98
60
18
29
33
50
44
57
21
10
27
42
28
47
29
28
10
17
25
35
43
33
46
7
19
18
19
35
32
23
0
11
31
21
33
36
20
6
46
0
25
39
26
9
21
0
26
40
21
50
22
11
31
33
56
58
25
33
12
39
45
31
25
42
22
17
20
31
34
50
42
27
15
25
30
32
18
26
22
18
24
25
35
29
46
31
16
17
28
27
22
23
14
13
22
15
20
12
17
7
0
7
4
5
6
3
1
3
0
0
2
1
1
1
0
0
0
0
0
0
0
0
0
0
0
0
0]';

% Had to reduce size of death vector ^^ from 1 x 147 to 1 x 116 to fit the
% parameters of hospitalization data (1 x 116). Scatterplot needed same
% size vectors to run. 

deathIncrease2 = [164
675
153
168
196
173
197
131
62
93
130
174
129
110
87
43
80
99
95
105
98
60
18
29
33
50
44
57
21
10
27
42
28
47
29
28
10
17
25
35
43
33
46
7
19
18
19
35
32
23
0
11
31
21
33
36
20
6
46
0
25
39
26
9
21
0
26
40
21
50
22
11
31
33
56
58
25
33
12
39
45
31
25
42
22
17
20
31
34
50
42
27
15
25
30
32
18
26
22
18
24
25
35
29
46
31
16
17
28
27
22
23
14
13
22
15]';

% Reorganize Data to show days from [oldest --> recent]

DeathIncTx = flip(deathIncrease);
DeathInc2Tx = flip(deathIncrease2);

% Moving Average Data Taken at Windows of 7,14,21,30 and 40 Days

% I renamed two the two moving averages as x and y when I made the video

DeathAvgTX = movmean(DeathIncTx,40); 
y = movmean(DeathInc2Tx,15); 
x = movmean(DailyHOSPTX,15);

% Normalize Data (Not part of scatterplot) 
DeathNormTX = normalize(DeathIncTx);
HospNormTX = normalize(DailyHOSPTX);

% Specify size and color of the dots on the scatterplot 
sz= 25;
c = linspace(1,116,length(x));

% Video file 

myVideo = VideoWriter('myVideoFile'); 
myVideo.FrameRate = 116;  
open(myVideo)

for i = 1:1:116
    scatter(x(i),y(i),sz,c(i))
    hold on 
    pause(0.1)
    frame = getframe(gcf); 
    writeVideo(myVideo, frame);
end
close(myVideo)


