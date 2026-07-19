# ----------------------------- Welcome Banner --------------------------
clear
# Redesigned Multi-color Clear ASCII Text Banner for DR.M.AKSHITH
echo -e "${RED_TEXT}  ██████╗ ██████╗ 🛑 ${YELLOW_TEXT}███╗   ███╗    ${GREEN_TEXT} █████╗ ██╗  ██╗███████╗██╗  ██╗██╗████████╗██╗  ██╗"
echo -e "${RED_TEXT}  ██╔══██╗██╔══██╗   ${YELLOW_TEXT}████╗ ████║    ${GREEN_TEXT}██╔══██╗██║ ██╔╝██╔════╝██║  ██║██║╚══██╔══╝██║  ██║"
echo -e "${CYAN_TEXT}  ██║  ██║██████╔╝   ${CYAN_TEXT}██╔████╔██║    ${BLUE_TEXT}███████║█████╔╝ ███████╗███████║██║   ██║   ███████║"
echo -e "${CYAN_TEXT}  ██║  ██║██╔══██╗   ${MAGENTA_TEXT}██║╚██╔╝██║    ${BLUE_TEXT}██╔══██║██╔═██╗ ╚════██║██╔══██║██║   ██║   ██╔══██║"
echo -e "${MAGENTA_TEXT}  ██████╔╝██║  ██║   ${MAGENTA_TEXT}██║ ╚═╝ ██║    ${RED_TEXT}██║  ██║██║  ██╗███████║██║  ██║██║   ██║   ██║  ██║"
echo -e "${MAGENTA_TEXT}  ╚══════╝ ╚═╝  ╚═╝   ${RED_TEXT}╚═╝     ╚═╝    ${RED_TEXT}╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝   ╚═╝   ╚═╝  ╚═╝"
echo -e "${RESET_FORMAT}"
echo -e "${CYAN_TEXT}${BOLD}────────────── Manage Terraform State GSP752 ──────────────${RESET_FORMAT}"
echo -e "${CYAN_TEXT}${BOLD}────────────── Terraform State: Local → GCS Backend + Import ──────────────${RESET_FORMAT}"

# ----------------------------- Disclaimer -----------------------------
echo
echo -e "${RED_TEXT}█${YELLOW_TEXT}█${GREEN_TEXT}█${CYAN_TEXT}█${BLUE_TEXT}█${MAGENTA_TEXT}█ ${YELLOW_TEXT}${BOLD}⚠️  DISCLAIMER & NOTICE:${RESET_FORMAT}"
echo -e "${WHITE}This script is automated specifically for lab environment verification platforms"
echo -e "(such as Google Cloud Skills Boost / Qwiklabs GSP752). It modifies state files,"
echo -e "provisions assets, and builds live instances."
echo
echo -e "${WHITE}Maintained and optimized by: "
echo -e "  ${RED_TEXT}D${YELLOW_TEXT}r${GREEN_TEXT}.${CYAN_TEXT}M${BLUE_TEXT}.${MAGENTA_TEXT}A${RED_TEXT}k${YELLOW_TEXT}s${GREEN_TEXT}h${CYAN_TEXT}i${BLUE_TEXT}t${MAGENTA_TEXT}h${RESET_FORMAT}"
echo
echo -e "${CYAN_TEXT}📺 YouTube Channel:${RESET_FORMAT}"
echo -e "  ${WHITE}https://youtube.com/@dr.m.akshith${RESET_FORMAT}"
echo
echo -e "${CYAN_TEXT}🌐 Original Deployment Source Commands:${RESET_FORMAT}"
echo -e "${WHITE}  curl -LO \"https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Manage%20Terraform%20State/akshith.sh\""
echo -e "  sudo chmod +x akshith.sh"
echo -e "  ./akshith.sh${RESET_FORMAT}"
echo
echo -e "${WHITE}Do not run this inside production environments without auditing changes.${RESET_FORMAT}"
echo



<div align="center">

# <span style="color:#FF0000; font-size: 3.5em; font-weight: 900; letter-spacing: 2px;">DR.</span> <span style="color:#FF7F00; font-size: 3.5em; font-weight: 900; letter-spacing: 2px;">M.</span> <span style="color:#00FF00; font-size: 3.5em; font-weight: 900; letter-spacing: 2px;">A</span><span style="color:#0000FF; font-size: 3.5em; font-weight: 900; letter-spacing: 2px;">K</span><span style="color:#4B0082; font-size: 3.5em; font-weight: 900; letter-spacing: 2px;">S</span><span style="color:#9400D3; font-size: 3.5em; font-weight: 900; letter-spacing: 2px;">H</span><span style="color:#FF0000; font-size: 3.5em; font-weight: 900; letter-spacing: 2px;">I</span><span style="color:#FF7F00; font-size: 3.5em; font-weight: 900; letter-spacing: 2px;">T</span><span style="color:#00FF00; font-size: 3.5em; font-weight: 900; letter-spacing: 2px;">H</span>

### 🌈 ⚡ Cloud DevOps Automation Suite ⚡ 🌈

---

## ⚠️ <span style="color:#FF0000;">D</span><span style="color:#FF7F00;">I</span><span style="color:#FFD700;">S</span><span style="color:#00FF00;">C</span><span style="color:#0000FF;">L</span><span style="color:#4B0082;">A</span><span style="color:#9400D3;">I</span><span style="color:#FF0000;">M</span><span style="color:#FF7F00;">E</span><span style="color:#00FF00;">R</span> & NOTICE

> [!WARNING]
> 📚 **Educational & Lab Verification Use Only!**  
> This script is automated specifically for lab environment verification platforms (such as Google Cloud Skills Boost / Qwiklabs GSP752). It modifies state files, provisions sandbox assets, and builds live instances. Do not deploy this suite inside production environments without conducting a prior resource audit. Always follow **Qwiklabs ToS**.

---

## Manage Terraform State
### 🚀 Lab ID: GSP752 🚀

<br/>

![](https://img.shields.io/badge/-%F0%9F%94%A5%20GOOGLE%20CLOUD%20ARCADE-FF6B6B?style=for-the-badge)
![](https://img.shields.io/badge/-%E2%98%81%EF%B8%8F%20TERRAFORM%20STATE-4ECDC4?style=for-the-badge)
![](https://img.shields.io/badge/-%F0%9F%90%9A%20SHELL%20SCRIPT-45B7D1?style=for-the-badge)

</div>

<br/>

---

![](https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=80&section=header&fontSize=0)

<div align="center">

## ⚡ `QUICK RUN` ⚡

</div>

<br/>

**🖥️ Open Cloud Shell → Paste → Done!**

```bash
curl -LO "[https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Manage%20Terraform%20State/akshith.sh](https://raw.githubusercontent.com/mardhaakshith2013-byte/ARCADE2026/main/Manage%20Terraform%20State/akshith.sh)"
sudo chmod +x akshith.sh
./akshith.sh


---

![](https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=80&section=footer&fontSize=0)

<div align="center">

## 🌍 Find Me Here

<br/>

[![YouTube](https://img.shields.io/badge/📹_YOUTUBE-Subscribe-FF0000?style=for-the-badge&logo=youtube&logoColor=white&labelColor=282828)](https://youtube.com/@dr.m.akshith?sub_confirmation=1)
[![GitHub](https://img.shields.io/badge/🐙_GITHUB-Follow_Me-181717?style=for-the-badge&logo=github&logoColor=white&labelColor=282828)](https://github.com/mardhaakshith2013-byte)

</div>

<br/>


CREDIT:-  GOOGLE SKILLS ARCADE
