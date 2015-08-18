//
//  ViewController.m
//  0420-音乐播放
//
//  Created by  on 15/4/20.
//  Copyright (c) 2015年 scjy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    
    AVAudioPlayer *player;
    UISlider *slider;
    UISlider *currentTime;
    NSTimer *timer;
    NSArray *arraySongs;
    int index;
    UIButton *button;
    NSDictionary *music;
    UIImageView *photo;
    float angle;
    UILabel *Totallable;
    UILabel *Nowlable;
    float width;
    UIPageControl *pageControl;
    UIScrollView *myScroll;
    NSString *content;
    NSArray *contentArray;
    
    NSMutableArray *menuMusic;
    
    int lrcLine;
    UITableView *lrcTableView;
    NSMutableArray *lrcContentArray;
    NSMutableArray *timeContentArray;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    [self initData];
    [self initView];
    
    
    
    [self getLrc];
    
//    for (int i=0; i<4; i++) {
//        [menuMusic addObject:lrcContentArray[0]];
//    }
  
}
-(void)initData{
    
    width=self.view.frame.size.width;
    lrcContentArray=[NSMutableArray array];
    timeContentArray=[NSMutableArray array];
     menuMusic=[NSMutableArray array];//歌单
    
    NSString *path1=[[NSBundle mainBundle]pathForResource:@"I Wanted You" ofType:@"mp3"];
    NSString *path2=[[NSBundle mainBundle]pathForResource:@"夜车" ofType:@"mp3"];
    NSString *path3=[[NSBundle mainBundle]pathForResource:@"Sparks Fly" ofType:@"mp3"];
    NSString *path4=[[NSBundle mainBundle]pathForResource:@"周杰伦-龙卷风" ofType:@"mp3"];
    
    UIImage *image1=[UIImage imageNamed:@"Ina"];
    UIImage *image2=[UIImage imageNamed:@"zeng"];
    UIImage *image3=[UIImage imageNamed:@"tailei"];
    UIImage *image4=[UIImage imageNamed:@"Jay.jpg"];
    NSArray *image=@[image1,image2,image3,image4];
    
    NSString *lrc1=[[NSBundle mainBundle]pathForResource:@"I wanted you" ofType:@"lrc"];
    NSString *lrc2=[[NSBundle mainBundle]pathForResource:@"夜车" ofType:@"lrc"];
    NSString *lrc3=[[NSBundle mainBundle]pathForResource:@"Sparks Fly" ofType:@"lrc"];
    NSString *lrc4=[[NSBundle mainBundle]pathForResource:@"龙卷风" ofType:@"lrc"];
    
    NSArray *arrayLrc=@[lrc1,lrc2,lrc3,lrc4];
    arraySongs=@[path1,path2,path3,path4];
   
    music=@{@"song":arraySongs,@"image":image,@"lrc":arrayLrc};
    [self getMusicMenu];
    
}
-(void)initView{
    
    NSError *error;
    
    NSLog(@"%@",arraySongs);
    player=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:music[@"song"][0]] error:&error];
    
    player.volume=0.9;
    player.currentTime=0.0;
    player.numberOfLoops=-1;
    player.delegate=self;
    
    if (error) {
        NSLog(@"错误描述：%@",[error description]);
    }
    
    [player prepareToPlay];
    //[player play];
#pragma mark-背景图片
    UIImageView *background=[[UIImageView alloc]initWithFrame:self.view.frame];
    background.image=[UIImage imageNamed:@"Music"];
    [self.view addSubview:background];
    
    slider=[[UISlider alloc]initWithFrame:CGRectMake(10, 70, 355, 20)];
    [slider addTarget:self action:@selector(changeVolum) forControlEvents:UIControlEventValueChanged];
    slider.value=0.5;
    slider.maximumValue=1.0;
    slider.minimumValue=0.0;
    [self.view addSubview:slider];
    
#pragma mark-时间进度
    currentTime=[[UISlider alloc]initWithFrame:CGRectMake(50, 510, 275, 20)];
    currentTime.minimumValue=0.0;
    currentTime.maximumValue=player.duration;
    [currentTime addTarget:self action:@selector(changeTime) forControlEvents:UIControlEventValueChanged];
    currentTime.maximumTrackTintColor=[UIColor whiteColor];
    [self.view addSubview:currentTime];
#pragma mark-左右标签
    Totallable=[[UILabel alloc]initWithFrame:CGRectMake(335, 510, 40, 20)];
    int minute=player.duration/60;
    int second=(int)player.duration%60;
    
    Totallable.text=[NSString stringWithFormat:@"0%d:%d",minute,second];
    Totallable.font=[UIFont systemFontOfSize:10];
    Totallable.textColor=[UIColor blackColor];
    [self.view addSubview:Totallable];
    
    Nowlable=[[UILabel alloc]initWithFrame:CGRectMake(12, 510, 40, 20)];
    int minute2=player.currentTime/60;
    int second2=(int)player.currentTime%60;
    
    Nowlable.text=[NSString stringWithFormat:@"0%d:%d",minute2,second2];
    Nowlable.font=[UIFont systemFontOfSize:10];
    Nowlable.textColor=[UIColor blackColor];
    [self.view addSubview:Nowlable];
    
    timer=[NSTimer timerWithTimeInterval:1 target:self selector:@selector(change) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSDefaultRunLoopMode];
    timer.fireDate=[NSDate distantFuture];
#pragma mark-控制按钮
    button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(150, 550, 75, 75);
    [button setTitle:@"Play" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor brownColor]];
    button.layer.cornerRadius=75/2;
    [button addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
    button.selected=YES;
    [self.view addSubview:button];
    
    
    UIButton *buttonNext=[UIButton buttonWithType:UIButtonTypeCustom];
    buttonNext.frame=CGRectMake(275, 560, 50, 50);
    [buttonNext setTitle:@"Next" forState:UIControlStateNormal];
    [buttonNext setBackgroundColor:[UIColor brownColor]];
    buttonNext.layer.cornerRadius=50/2;
    [buttonNext addTarget:self action:@selector(nextSong) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonNext];
    
    UIButton *buttonLast=[UIButton buttonWithType:UIButtonTypeCustom];
    buttonLast.frame=CGRectMake(50, 560, 50, 50);
    [buttonLast setTitle:@"Last" forState:UIControlStateNormal];
    [buttonLast setBackgroundColor:[UIColor brownColor]];
    buttonLast.layer.cornerRadius=50/2;
    [buttonLast addTarget:self action:@selector(lastSong) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonLast];
    
#pragma mark-指示器
    
    myScroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 120, width, 350)];
    //myScroll.backgroundColor=[UIColor grayColor];
    myScroll.contentSize=CGSizeMake(width*3, 330);
    myScroll.pagingEnabled=YES;
    myScroll.delegate=self;
    myScroll.showsHorizontalScrollIndicator=NO;
    [self.view addSubview:myScroll];
    
    pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0, 470, width, 20)];
    pageControl.numberOfPages=3;
    [pageControl addTarget:self action:@selector(changePage) forControlEvents:UIControlEventValueChanged];
    pageControl.pageIndicatorTintColor=[UIColor brownColor];
    pageControl.currentPageIndicatorTintColor=[UIColor orangeColor];
    [self.view addSubview:pageControl];
    
    UITableView *songMenu=[[UITableView alloc]initWithFrame:CGRectMake(0, 100, width, 205)];
    songMenu.delegate=self;
    songMenu.tag=100;
    songMenu.backgroundColor=[UIColor clearColor];
    songMenu.dataSource=self;
    
    [myScroll addSubview:songMenu];
    
    photo=[[UIImageView alloc]initWithFrame:CGRectMake(width+80, 100, 205, 205)];
    photo.image=[UIImage imageNamed:@"Ina"];
    photo.layer.cornerRadius=205/2;
    photo.layer.masksToBounds=YES;
    
    //photo.transform=CGAffineTransformMakeRotation(0.5);
    [myScroll addSubview:photo];
    
    NSTimer *imageTimer=[NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(changeImage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:imageTimer forMode:NSDefaultRunLoopMode];
    
    UIImageView *photo1=[[UIImageView alloc]initWithFrame:CGRectMake(width+177.5, 202.5, 10, 10)];
    photo1.backgroundColor=[UIColor whiteColor];
    photo1.layer.cornerRadius=10/2;
    photo1.layer.masksToBounds=YES;
    [myScroll addSubview:photo1];
    
#pragma mark-歌词显示
    
    lrcTableView=[[UITableView alloc]initWithFrame:CGRectMake(width*2, 0, width, 350)];
    lrcTableView.backgroundColor=[UIColor clearColor];
    lrcTableView.delegate=self;
    lrcTableView.showsVerticalScrollIndicator=NO;
    lrcTableView.dataSource=self;
    lrcTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [myScroll addSubview:lrcTableView];
    
    content=[[NSString alloc]initWithContentsOfFile:music[@"lrc"][0] encoding:NSUTF8StringEncoding error:nil];
    contentArray=[content componentsSeparatedByString:@"\n"];

}
-(void)getMusicMenu{
    
    for (int i=0; i<4; i++) {
        NSString *content1=[[NSString alloc]initWithContentsOfFile:music[@"lrc"][i] encoding:NSUTF8StringEncoding error:nil];
        contentArray=[content1 componentsSeparatedByString:@"\n"];
        [self getLrc];
    }
    
    NSLog(@"%@",menuMusic);
    
}

#pragma mark-分页小点
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    int page=myScroll.contentOffset.x/width;
    pageControl.currentPage=page;
    
}
-(void)changePage{
    
    myScroll.contentOffset=CGPointMake(width*pageControl.currentPage, 0) ;
    
}
#pragma mark-暂停播放
-(void)playOrPause:(UIButton *)sender{
    
    if (sender.selected) {
        timer.fireDate=[NSDate distantPast];
        [sender setTitle:@"Pasue" forState:UIControlStateNormal];
        sender.selected=NO;
        [player play];
    }else{
        timer.fireDate=[NSDate distantFuture];
        [sender setTitle:@"Play" forState:UIControlStateNormal];
        sender.selected=YES;
        [player pause];
    }
}
#pragma mark-下一首
-(void)nextSong{
    
    NSError *error;
    index++;
    if (index==4) {
        index=0;
    }
    player=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:music[@"song"][index]] error:&error];
    [player prepareToPlay];
    [player play];
    [button setTitle:@"Pasue" forState:UIControlStateNormal];
    button.selected=NO;
    timer.fireDate=[NSDate distantPast];
    photo.image=music[@"image"][index];
    
    
    //[menuMusic addObject:lrcContentArray[0]];
    //NSLog(@"%@",menuMusic);
    
    lrcContentArray=[NSMutableArray array];
    timeContentArray=[NSMutableArray array];
    
    content=[[NSString alloc]initWithContentsOfFile:music[@"lrc"][index] encoding:NSUTF8StringEncoding error:nil];
    contentArray=[content componentsSeparatedByString:@"\n"];
    
    [self getLrc];
    int minute=player.duration/60;
    int second=(int)player.duration%60;
    
    Totallable.text=[NSString stringWithFormat:@"0%d:%d",minute,second];
    currentTime.maximumValue=player.duration;
}
#pragma mark-上一首
-(void)lastSong{
    NSError *error;
    index--;
    if (index==-1) {
        index=3;
    }
    player=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:music[@"song"][index]] error:&error];
    [player prepareToPlay];
    [player play];
    [button setTitle:@"Pasue" forState:UIControlStateNormal];
    button.selected=NO;
    timer.fireDate=[NSDate distantPast];
    photo.image=music[@"image"][index];
    
    lrcContentArray=[NSMutableArray array];
    timeContentArray=[NSMutableArray array];
    
    content=[[NSString alloc]initWithContentsOfFile:music[@"lrc"][index] encoding:NSUTF8StringEncoding error:nil];
    contentArray=[content componentsSeparatedByString:@"\n"];
    
    [self getLrc];

    
    int minute=player.duration/60;
    int second=(int)player.duration%60;
    
    Totallable.text=[NSString stringWithFormat:@"0%d:%d",minute,second];
    currentTime.maximumValue=player.duration;
}
#pragma mark-进度条
-(void)changeTime{
    
    player.currentTime=currentTime.value;
    
}
-(void)change{
    
    currentTime.value=player.currentTime;
    [self displaysongLrc:(NSUInteger)currentTime.value];
    
    int minute2=player.currentTime/60;
    int second2=(int)player.currentTime%60;
    
    Nowlable.text=[NSString stringWithFormat:@"0%d:%d",minute2,second2];
    
}
#pragma mark-音量
-(void)changeVolum{
    
    player.volume=slider.value;
    
}

#pragma mark-转动图片
-(void)changeImage{
    angle+=0.01;
    if (angle>6.28) {
        angle=0;
        
    }
    //lrcLine+=1;
    
    photo.transform=CGAffineTransformMakeRotation(angle);
   // [self updataLrc:lrcLine];
    
    //CGAffineTransform transform= CGAffineTransformMakeRotation(M_PI*0.38);
    /*关于M_PI
     #define M_PI     3.14159265358979323846264338327950288
     其实它就是圆周率的值，在这里代表弧度，相当于角度制 0-360 度，M_PI=180度
     旋转方向为：顺时针旋转  最大值是6.28，360度
     */
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag==100) {
        
        return 4;
        
    }else{
        
        NSLog(@"歌词行数%ld",lrcContentArray.count);
        return lrcContentArray.count;
    }
    
    
}
#pragma mark-tableview
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag==100) {
        
        static NSString *cellID=@"cellIndefier";
        UITableViewCell *cellMenu=[tableView dequeueReusableCellWithIdentifier:cellID];
        
        if (!cellMenu) {
            cellMenu=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cellMenu.backgroundColor=[UIColor clearColor];
        }
        
        cellMenu.textLabel.text=menuMusic[indexPath.row];
        return cellMenu;
    }
    static NSString *cellID=@"cellIndefier";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor=[UIColor clearColor];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
    }
    
    if (lrcLine==indexPath.row) {
        cell.textLabel.textColor=[UIColor blueColor];
    }else{
        cell.textLabel.textColor=[UIColor blackColor];
    }
    
    cell.textLabel.text=lrcContentArray[indexPath.row];
    cell.textLabel.textAlignment=1;
    
    //NSLog(@"%@",contentArray[indexPath.row]);
        return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (tableView.tag==100) {
        
        NSLog(@"%ld",indexPath.row);
        NSError *error;
        
        player=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:music[@"song"][indexPath.row]] error:&error];
        [player prepareToPlay];
        [player play];
        [button setTitle:@"Pasue" forState:UIControlStateNormal];
        button.selected=NO;
        timer.fireDate=[NSDate distantPast];
        photo.image=music[@"image"][indexPath.row];
        
        lrcContentArray=[NSMutableArray array];
        timeContentArray=[NSMutableArray array];
        
        content=[[NSString alloc]initWithContentsOfFile:music[@"lrc"][indexPath.row] encoding:NSUTF8StringEncoding error:nil];
        contentArray=[content componentsSeparatedByString:@"\n"];
        
        [self getLrc];
        int minute=player.duration/60;
        int second=(int)player.duration%60;
        
        Totallable.text=[NSString stringWithFormat:@"0%d:%d",minute,second];
        currentTime.maximumValue=player.duration;
        
       
        
    }
    
    
}

#pragma mark-动态显示歌词



-(void)getLrc{
    lrcContentArray=[NSMutableArray array];
    for (int i=0; i<contentArray.count; i++) {
        NSString *lineLrc=contentArray[i];
        
        NSArray *lineArray=[lineLrc componentsSeparatedByString:@"]"];
        if ([lineArray[0] length]>5) {
            NSString *str1=[lineLrc substringWithRange:NSMakeRange(3,1)];
            NSString *str2=[lineLrc substringWithRange:NSMakeRange(6,1)];
            
            if ([str1 isEqualToString:@":"] && [str2 isEqualToString:@"."]) {
                
                NSString *lrcStr=lineArray[1];
                NSString *timeStr=[lineArray[0] substringWithRange:NSMakeRange(1, 5)];
                [lrcContentArray addObject:lrcStr];
                [timeContentArray addObject:timeStr];
                
            }
        }
    }
    [menuMusic addObject:lrcContentArray[0]];
}
-(void)displaysongLrc:(NSUInteger)time{
    for (int i = 0; i < [timeContentArray count]; i++) {
        NSArray *array = [timeContentArray[i] componentsSeparatedByString:@":"];//把时间转换成秒
        NSUInteger currentTime0 = [array[0] intValue] * 60 + [array[1] intValue];
        
        if (i == [timeContentArray count]-1) {
            //求最后一句歌词的时间点
            NSArray *array1 = [timeContentArray[timeContentArray.count-1] componentsSeparatedByString:@":"];
            NSUInteger currentTime1 = [array1[0] intValue] * 60 + [array1[1] intValue];
            if (time > currentTime1) {
                [self updataLrc:i];
                break;
            }
        } else {
            //求出第一句的时间点，在第一句显示前的时间内一直加载第一句
            NSArray *array2 = [timeContentArray[0] componentsSeparatedByString:@":"];
            NSUInteger currentTime2 = [array2[0] intValue] * 60 + [array2[1] intValue];
            if (time < currentTime2) {
                [self updataLrc:0];
                //                NSLog(@"马上到第一句");
                break;
            }
            //求出下一步的歌词时间点，然后计算区间
            NSArray *array3 = [timeContentArray[i+1] componentsSeparatedByString:@":"];
            NSUInteger currentTime3 = [array3[0] intValue] * 60 + [array3[1] intValue];
            if (time >= currentTime0 && time <= currentTime3) {
                [self updataLrc:i];
                break;
            }
            
        }
    }
}
-(void)updataLrc:(int)nowLine{
    
    NSLog(@"现在%d",nowLine);
    lrcLine=nowLine;
    NSIndexPath *indexPath=[NSIndexPath indexPathForItem:nowLine inSection:0];
    [lrcTableView reloadData];
    [lrcTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
