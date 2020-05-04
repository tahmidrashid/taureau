from textblob import TextBlob
import pandas as pd
import re
def getSentimentPolarity(x):
    testimonial=TextBlob(x['text'])
    s=testimonial.sentiment.polarity
    return s
def getSentimentSubjectivity(x):
    testimonial=TextBlob(x['text'])
    s=testimonial.sentiment.subjectivity
    return s
def cleanText(x):
    import re
    str1=x['text']
    str2=re.split('RT @\w+: ',str1)
    if(len(str2))==2:
        return str2[1]
    else:
        return str2[0]
		
inname="Tesla/Tesla-2020-3-16"
infile=open(inname+".json")
df = pd.DataFrame()
for lines in infile:
    try:
        df0=pd.read_json(lines)
        df=df.append(df0)
    except:
        None
infile.close()

filename=inname
#df=pd.read_json(filename+".json", lines=True)
df=df[['created_at','text']]
df['Polarity']=0
df['Subjectivity']=0
df['text']=df.apply(cleanText, axis=1)
df['Polarity']=df.apply(getSentimentPolarity, axis=1)
df['Subjectivity']=df.apply(getSentimentSubjectivity, axis=1)
df['Aggregate Score']=df['Polarity']*0.5+df['Subjectivity']*0.5
df.to_csv(filename+".csv")
print(df["Polarity"].mean())
print(df["Subjectivity"].mean())
print(df["Aggregate Score"].mean())


df